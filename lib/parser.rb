# coding: UTF-8

require 'open-uri'

class Parser
  attr_accessor :uri, :lines, :current_line, :work

  def initialize(work_uri)
    @work = Work.new
    @work.uri = work_uri
    parse_work
    @work.tables.each do |table|
      table.schema = parse_table(table.uri)
    end
    pp @work
  end

  def parse_work
    parser = Nokogiri::HTML.parse(open(@work.uri).read)
    @work.name = parser.at_xpath("//h1").text
    @work.tags = Array.new
    parser.xpath("//a[@class='tagLink']").each do |tag|
      @work.tags << tag.text
    end
    @work.creator = parser.at_xpath("//div[@class='userlist']//a").text
    @work.tables = Array.new
    parser.xpath("//table[@id='downloadTable']//tbody").each do |file|
      table = Table.new
      table.name = file.at_xpath("tr/td/span/a").text.chomp.strip
      #table.uri = URI.parse(@work.uri).merge(file.at_xpath("tr/td/span/a/@href").text.chomp.strip).to_s
      table.uri = URI.parse(@work.uri).merge(file.at_xpath("tr/td[preceding::td[1][normalize-space(text())='テーブルデータ']]/a/@href").text.chomp.strip).to_s
      p table.uri
      @work.tables << table
    end
  end


  def parse_table(table_uri)
    @current_line = 0
    @lines = open(table_uri).map do |line|
      line.chomp.strip.split("\t")
    end
    schema = Schema.new
    schema.creator = Person.new
    schema.properties = Array.new
    schema.namespaces = {
      :xsd => 'http://www.w3.org/2001/XMLSchema#'
    }
    @lines.each_with_index do |line, index|
      @current_line = index
      case line.first
      when /^#/
        parse_comment_line(schema)
      else
        parse_data_line
      end
    end
    return schema
  end

  def parse_comment_line(schema)
    # p "コメント行"
    line = @lines[@current_line]
    case line.first
    when '#lang'
      schema.language = line[1]
    when '#attribution_name'
      schema.creator.name = line[1]
    when '#attribution_url'
      schema.creator.uri = line[1]
    when '#license'
      schema.license = line[1]
    when '#file_name'
      schema.file_name = line[1]
    when '#download_from'
      schema.download_from = line[1]
    when '#namespace'
      schema.namespaces[line[1]] = line[2]
    when '#property'
      properties = @lines[@current_line...@current_line+3].transpose
      properties.shift
      properties = properties.inject(Hash.new(0)) {|h, key| h[key] += 1; h}
      properties.each do |property, max_cardinality|
        prop = Property.new
        if property[0].uri?
          # #propertyに，名前空間による省略無しでURIが書いてある
          prop.uri = property[0]
          begin
            prop.label = property[0].to_label
          rescue
            prop.label = property[0].split(/#|\//).last
          end
        else
          if property[0] =~ /^.+:.+$/
            # #propertyに，名前空間による省略有りでURIが書いてある
            prop.uri = property[0].prefix_to_uri(@schema.namespaces)
            prop.label = prop.uri.to_label
          else
            # #propertyに，URIが書かれていない
            prop.label = property[0]
          end
        end
        prop.value_type = schema.namespaces[:xsd] + property[1]
        prop.context = property[2]
        prop.max_cardinality = max_cardinality
        schema.properties << prop
      end
    end
  end

  def parse_data_line
    # p "データ行"
  end
end
