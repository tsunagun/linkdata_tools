# coding: UTF-8

require 'uri'
require 'cgi'
require 'open-uri'
require 'rsolr'
require 'nokogiri'

class String
  # 文字列がURIか否かを確かめるメソッド
  def http_uri?
    begin
      uri = URI.parse(self)
      case uri.scheme
      when "http"
        true
      when "https"
        true
      else
        return false
      end
    rescue URI::InvalidURIError
      return false
    end
  end

  # 名前空間接頭辞を使用したURIを，名前空間接頭辞を使用しないURIに置き換える
  def prefix_to_uri(namespaces)
    begin
      prefix, label = self.split(":")
      namespaces[prefix.to_sym] + label
    rescue
      self
    end
  end

  # タームURIのラベル（rdfs:label）を求める
  def to_label
    base_uri = 'http://www.metabridge.jp/infolib/metabridge/show/term/view/?lang=&termURI='
    sleep 1
    response = open(base_uri + CGI.escape(self)).read
    parser = Nokogiri::HTML.parse(response)
    label = parser.at_xpath("//table//td[preceding::th/text()='ラベル']").text rescue nil
    return label
  end
end
