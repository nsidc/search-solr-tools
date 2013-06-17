require 'rest_client'
require 'nokogiri'

class SolrSearchPage
  def initialize(host, port, collection_path)
    @url = "http://#{host}:#{port}/#{collection_path}"
  end

  def query(terms)
    query_url = "#{@url.dup}/select?q=#{URI::encode(terms)}"

    @response = RestClient.get query_url
    @response_doc = Nokogiri::XML @response.body
  end

  def is_valid?
    @response.code.eql?(200)
  end

  def total_results
    @response_doc.at_xpath('//result').attribute('numFound').text.to_i
  end

  def results
    @response_doc.xpath('//doc')
  end
end