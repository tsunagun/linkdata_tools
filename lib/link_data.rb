# coding: UTF-8

require 'pp'
require './lib/string'
require './lib/link_data/person'
require './lib/link_data/schema'
require './lib/link_data/property'
require './lib/link_data/parser'
require './lib/link_data/work'
require './lib/link_data/table'


module LinkData
end


work_uri = ARGV[0] || 'http://ja.linkdata.org/work/rdf1s328i#work_information'
puts LinkData::Work.parse(work_uri).to_easy_dsp
