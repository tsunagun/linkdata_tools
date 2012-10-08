# coding: UTF-8
# LinkDataに登録された任意のデータセットから，簡易DSPを生成
# スクリプト実行時の引数で，データセットURIを指定できる
# 簡易DSPは標準出力される
# 使用例：
#   ruby ld2mb.rb > out.tsv
#
# ※注意※
# MetaBridgeに登録するためには，プロパティや値制約を名前空間接頭辞付きURIに置き換える必要がある．
# 現在は修正を行う処理を作成していないので，出力された簡易DSPを手作業で置き換えなければならない．
require 'open-uri'
require 'nokogiri'
require 'rdf'
require 'csv'
require 'pp'

module MetaBridge
  def self.ns_section(namespaces)
    ns_section = Array.new
    ns_section << %w([@NS])
    namespaces.each do |uri, prefix|
      ns_section << [prefix, uri]
    end
    return ns_section
  end

  def self.main_section(properties)
    main_section = Array.new
    main_section << %w([MAIN])
    main_section << %w(#項目規則名 プロパティ 最小 最大 値タイプ 値制約 説明)
    properties.each do |property|
      main_section << [property.label, property.uri, 1, 1, "文字列", property.obj_type]
    end
    return main_section
  end
end

class Schema
  attr_accessor :id, :work_base_uri, :property_base_uri, :creator, :properties

  def initialize(uri)
    ary = uri.split("/")
    @id = ary[4]
    @work_base_uri = "http://linkdata.org/work/#{id}#"
    @property_base_uri = "http://linkdata.org/property/#{id}#"
    @creator = nil
    @properties = get_info(uri)
  end

  def get_info(uri)
    doc = open(uri).read
    parser = Nokogiri::HTML.parse(doc)
    props, names, obj_types, prop_contexts = Array.new, Array.new, Array.new, Array.new
    parser.xpath("//tr[td/@class='header']").each do |row|
      case row.at_xpath("td[@class='header']").text
      when "#attribution_name"
        @creator = row.at_xpath("td[2]").text
      when "#property"
        props = row.xpath("td[@class='property']").map do |prop|
          prop.text
        end
      when "#object_type_xsd"
        obj_types = row.xpath("td[@class='property']").map do |obj_type|
          RDF::XSD.send(obj_type.text.gsub(/:.*$/, "")).to_s
        end
      when "#property_context"
        prop_contexts = row.xpath("td[@class='property']").map do |prop_context|
          prop_context.text
        end
      end
    end
    properties = Array.new
    properties = props.each_with_index.map do |prop, index|
      property = Property.new
      property.uri = prop =~ /^http:\/\// ? prop : (@property_base_uri + prop).gsub(/\s/, "_")
      property.label = prop.delete_namespaces
      property.obj_type = obj_types[index]
      property.context = prop_contexts[index]
      property
    end
    return properties
  end
end

class Property
  attr_accessor :uri, :label, :obj_type, :context
end

class String
  def delete_namespaces
    self.split(/\/|#/).last
  end
end

# LinkDataのHTML tableから，変換用の中間形式schemaを作成
uri = ARGV[0] || "http://linkdata.org/work/rdf1s12i/Highest_Mountains_in_Japan.html"
schema = Schema.new(uri)

# 名前空間宣言．今回は使用しない
namespaces = {}

# 名前空間セクションとMAINセクションを生成し結合
rows = MetaBridge.ns_section(namespaces).push([]) + MetaBridge.main_section(schema.properties)

# TSVで出力
str = CSV.generate(:col_sep => "\t") do |writer|
  rows.each do |row|
    writer << row
  end
end
print str
