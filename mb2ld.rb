require 'spreadsheet'
require 'charlock_holmes'
require 'dsp'
require 'pp'

class Property
  attr_accessor :uri, :label, :obj_type, :context
end

dsp_uri = ARGV[0] || "http://www.infocom.co.jp/dsp/sample"
metabridge_base_uri = "http://www.metabridge.jp/infolib/metabridge/api/description?graph="
dspfile = metabridge_base_uri + dsp_uri
ActsAsRDF.repository = RDF::Repository.load(dspfile)
creator = DSP::DescriptionSetTemplate.find(RDF::URI.new(dsp_uri)).creator.to_s
dt = DSP::DescriptionTemplate.find(RDF::URI.new(dsp_uri + "#MAIN"))
properties = dt.statement_templates.map do |statement_template|
  property = Property.new
  property.uri = statement_template.on_property.to_s
  property.label = statement_template.label.to_s
  property.obj_type = (statement_template.on_class || statement_template.on_data_range).to_s
  property.context = "assertion"
  property
end

Spreadsheet.client_encoding = 'Shift_JIS'
book = Spreadsheet::Workbook.new
sheet = book.create_worksheet
sheet.name = "Sample"

rows = Array.new
rows << ["#LINK"]
rows << ["#file_name", "book"]
rows << ["#lang", "ja"]
rows << ["#attribution_name", creator]
rows << ["#attribution_url"]
rows << ["#property"] + properties.map do |property| property.uri end
rows << ["#object_type_xsd"] + properties.map do |property| property.obj_type end
rows << ["#property_context"] + properties.map do |property| property.context end
rows.each_with_index do |row, index|
  sheet.row(index).replace(row)
end
book.write('out.xls')
