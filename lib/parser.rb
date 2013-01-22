# coding: UTF-8

require 'open-uri'

class Parser
  attr_accessor :uri, :lines, :current_line, :work

  def initialize(work_uri)
    pp Work.parse(work_uri)
  end



end
