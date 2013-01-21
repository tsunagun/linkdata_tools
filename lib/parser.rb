# coding: UTF-8

require 'open-uri'

class Parser
  attr_accessor :filename, :lines, :current_line, :schema
  def initialize(filename)
    @filename = filename
    @lines = open(filename).map do |line|
      line.chomp.strip.split("\t")
    end
    @current_line = 0
    @schema = Schema.new
    @schema.creator = Person.new
    @schema.properties = Array.new
    @schema.namespaces = {
      :xsd => 'http://www.w3.org/2001/XMLSchema#'
    }
  end

  def parse
    @lines.each_with_index do |line, index|
      @current_line = index
      case line.first
      when /^#/
        parse_comment_line
      else
        parse_data_line
      end
    end
    return @schema
  end

  def parse_comment_line
    # p "コメント行"
    line = @lines[@current_line]
    case line.first
    when '#lang'
      @schema.language = line[1]
    when '#attribution_name'
      @schema.creator.name = line[1]
    when '#attribution_url'
      @schema.creator.uri = line[1]
    when '#license'
      @schema.license = line[1]
    when '#file_name'
      @schema.file_name = line[1]
    when '#download_from'
      @schema.download_from = line[1]
    when '#namespace'
      @schema.namespaces[line[1]] = line[2]
    when '#property'
      properties = @lines[@current_line...@current_line+3].transpose
      properties.shift
      properties = properties.inject(Hash.new(0)) {|h, key| h[key] += 1; h}
      properties.each do |property, max_cardinality|
        prop = Property.new
        if property[0].uri?
          prop.uri = property[0]
          begin
            prop.label = property[0].to_label
          rescue
            prop.label = property[0].split(/#|\//).last
          end
        else
          prop.label = property[0]
        end
        prop.value_type = @schema.namespaces[:xsd] + property[1]
        prop.context = property[2]
        prop.max_cardinality = max_cardinality
        @schema.properties << prop
      end
    end
  end

  def parse_data_line
    # p "データ行"
  end
end
