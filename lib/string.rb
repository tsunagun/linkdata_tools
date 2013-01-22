# coding: UTF-8

require 'uri'
require 'cgi'
require 'open-uri'
require 'rsolr'
require 'nokogiri'

class String
  # 文字列がURIか否かを確かめるメソッド
  def uri?
    begin
      uri = URI.parse(self)
      return true
    rescue URI::InvalidURIError
      return false
    end
  end

  # プロパティURIからプロパティのラベルを求めるメソッド
  # 小早川さんが収集した語彙定義情報のSolrが必要
  # Solrからのデータ取得に失敗した場合は，URIの最後のスラッシュ以降，あるいは最後のハッシュ以降をラベルとする
=begin
  def to_label
    solr = RSolr.connect :uri => 'http://localhost:8983/solr'
    response = solr.get 'select', :params => {:q => "URI:\"#{self}\"", :format => :json}
    return response['response']['docs'].first['Name'] rescue nil
  end
=end

  def prefix_to_uri(namespaces)
    prefix, label = self.split(":").first
    namespaces[prefix.to_sym] + label
  end

  def to_label
    base_uri = 'http://www.metabridge.jp/infolib/metabridge/show/term/view/?lang=&termURI='
    response = open(base_uri + CGI.escape(self)).read
    parser = Nokogiri::HTML.parse(response)
    label = parser.at_xpath("//table//td[preceding::th/text()='ラベル']").text rescue nil
    return label
  end
end
