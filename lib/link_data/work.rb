# coding: UTF-8

module LinkData
  class LinkData::Work
    attr_accessor :uri, :name, :creator, :tags, :tables, :description

    def self.parse(work_uri)
      work = LinkData::Work.new
      work.uri = work_uri
      sleep 1
      parser = Nokogiri::HTML.parse(open(work_uri).read)
      work.name = parser.at_xpath("//h1").text
      work.creator = parser.at_xpath("//div[@class='userlist']//a").text
      work.tags = Array.new
      parser.xpath("//a[@class='tagLink']").each do |tag|
        work.tags << tag.text
      end
      work.tables = Array.new
      parser.xpath("//table[@id='downloadTable']//tbody").each do |file|
        table_uri = URI.parse(work.uri).merge(file.at_xpath("tr/td[preceding::td[1][normalize-space(text())='テーブルデータ']]/a/@href").text.chomp.strip).to_s
        table = LinkData::Table.parse(table_uri)
        work.tables << table
      end
      return work
    end

    def to_easy_dsp
      lines = Array.new
=begin
      lines << '[@NS]'
      self.tables.schema.namespaces.each do |key, value|
        lines << [key.to_s, value].join("\t")
      end
=end
      self.tables.each do |table|
        lines << ''
        lines << "[#{table.name}]"
        lines << ['#項目規則名', 'プロパティ', '最小', '最大', '値タイプ', '値制約', '説明'].join("\t")
        table.schema.properties.each do |property|
          lines << [property.label, property.uri, 1, property.max_cardinality, '文字列', property.value_type].join("\t")
        end
      end
      return lines
    end
  end
end
