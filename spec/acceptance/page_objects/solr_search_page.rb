require 'rest_client'
require 'nokogiri'

# class to query solr with specific terms and examine the results as Nokogiri documents
class SolrSearchPage
  def initialize(host, port, collection_path, collection)
    @url = "http://#{host}:#{port}/#{collection_path}/#{collection}"
  end

  def query(terms)
    query_url = "#{@url.dup}/select?q=#{URI.encode(terms)}&qf=title&defType=edismax"

    @response = RestClient.get query_url
    @response_doc = Nokogiri.XML @response.body
  end

  def valid?
    @response.code.eql?(200)
  end

  def total_results
    @response_doc.at_xpath('//result').attribute('numFound').text.to_i
  end

  def results
    @response_doc.xpath('//doc')
  end
end
