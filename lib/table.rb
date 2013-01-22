# coding: UTF-8

class Table
  attr_accessor :name, :uri, :schema

  def self.parse(table_uri)
    table = Table.new
    table.uri = table_uri
    current_line = 0
    sleep 1
    lines = open(table.uri).map do |line|
      line.chomp.strip.split("\t")
    end
    table.schema = Schema.new
    table.schema.creator = Person.new
    table.schema.properties = Array.new
    table.schema.namespaces = {
      :xsd => 'http://www.w3.org/2001/XMLSchema#'
    }
    lines.each_with_index do |line, index|
      current_line = index
      case line.first
      when /^#/
        Table.parse_comment_line(lines, current_line, table.schema)
      else
        Table.parse_data_line(lines, current_line, table.schema)
      end
    end
    table.name = table.schema.file_name
    return table
  end

  def self.parse_comment_line(lines, current_line, schema)
    # p "コメント行"
    line = lines[current_line]
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
      schema.namespaces[line[1].to_sym] = line[2]
    when '#property'
      properties = lines[current_line...current_line+3].transpose
      properties.shift
      properties = properties.inject(Hash.new(0)) {|h, key| h[key] += 1; h}
      properties.each do |property, max_cardinality|
        prop = Property.new
        if property[0].http_uri?
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
            prop.uri = property[0].prefix_to_uri(schema.namespaces)
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

  def self.parse_data_line(lines, current_line, schema)
    # p "データ行"
  end
end
