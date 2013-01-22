# coding: UTF-8

require 'pp'
require './lib/string'
require './lib/person'
require './lib/schema'
require './lib/property'
require './lib/parser'
require './lib/work'
require './lib/table'

work_uri = ARGV[0] || 'http://ja.linkdata.org/work/rdf1s328i#work_information'
Parser.new(work_uri)
=begin
schema = Parser.new(ARGV[0]).work

lines = Array.new
lines << '[@NS]'
schema.namespaces.each do |key, value|
  lines << [key.to_s, value].join("\t")
end
lines << ''
lines << '[MAIN]'
lines << ['#項目規則名', 'プロパティ', '最小', '最大', '値タイプ', '値制約', '説明'].join("\t")
schema.properties.each do |property|
  lines << [property.label, property.uri, 1, property.max_cardinality, '文字列', property.value_type].join("\t")
end
puts lines
=end
