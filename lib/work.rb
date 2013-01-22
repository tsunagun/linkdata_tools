# coding: UTF-8

class Work
  attr_accessor :uri, :name, :creator, :tags, :tables, :description

  def self.parse(work_uri)
    work = Work.new
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
      table = Table.parse(table_uri)
      work.tables << table
    end
    return work
  end
end
