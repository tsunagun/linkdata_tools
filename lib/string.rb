# coding: UTF-8

require 'uri'
require 'rsolr'

class String
  # 文字列がURIか否かを確かめるメソッド
  def uri?
    begin
      uri = URI.parse(self)
      return true
    rescue URI::InvalidURIError
      return false
    end
  end

  # プロパティURIからプロパティのラベルを求めるメソッド
  # 小早川さんが収集した語彙定義情報のSolrが必要
  # Solrからのデータ取得に失敗した場合は，URIの最後のスラッシュ以降，あるいは最後のハッシュ以降をラベルとする
  def to_label
    solr = RSolr.connect :uri => 'http://localhost:8983/solr'
    response = solr.get 'select', :params => {:q => "URI:\"#{self}\"", :format => :json}
    return response['response']['docs'].first['Name'] rescue nil
  end
end
