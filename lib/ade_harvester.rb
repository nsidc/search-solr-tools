require 'rest-client'
require 'nokogiri'
require 'open-uri'
require './lib/ade_csw_iso_query_builder'
require './lib/ade_iso_to_solr'

class ADEHarvester
  ISO_NAMESPACES = { 'gmd' => 'http://www.isotc211.org/2005/gmd',  'gco' => 'http://www.isotc211.org/2005/gco' }

  attr_accessor :environment, :gi_cat_url

  def initialize( env="development" )
    @environment = env
    @csw_query_url = SolrEnvironments[@environment][:gi_cat_csw_url]
    @solr_url = "http://" + SolrEnvironments[@environment][:host] + ":" + SolrEnvironments[@environment][:port] + "/" + SolrEnvironments[@environment][:collection_path]
  end

  def getNumberOfRecords
    queryString = buildCswRequest("hits", "1", "1")
    resultsCount = Nokogiri::XML(open(queryString)).xpath("//csw:SearchResults").first['numberOfRecordsMatched']

    return resultsCount.to_i
  end

  def getResults pageSize, startIndex
    queryString = buildCswRequest("results", pageSize, startIndex)
    return Nokogiri::XML(open(queryString))
  end

  def getRecords
    start_index = 1
    page_size = 100
    numRecords = getNumberOfRecords

    translator = ADEIsoToSolr.new :cisl

    solr_docs_builder = Nokogiri::XML::Builder.new do |xml|
      xml.add
    end

    solr_docs = solr_docs_builder.doc

    while start_index - 1 < numRecords

      results = getResults(page_size, start_index)
      entries = results.xpath('.//gmd:MD_Metadata', ISO_NAMESPACES)

      entries.each do |entry|
        translated_entry = translator.translate entry
        solr_docs.root.add_child translated_entry.root
      end

      start_index += page_size
    end

    return solr_docs.to_xml
  end

  # Update Solr with a set of documents
  def insertSolrDocs solrDocs
    url = @solr_url + "/update?commit=true"

    response = RestClient.post(url,
                    solrDocs,
                               {:Content_Type => 'text/xml; charset=utf-8'}) { |response, request, result|

      return response.code
}
  end

  def harvest
    resultsXml = getRecords
    insertSolrDocs(resultsXml)
  end

  def buildAddXMLMessage solrDocs
    docs = Nokogiri::XML("<add>" + solrDocs + "</add>")
    return docs.to_xml
  end

  def buildCswRequest(resultType = 'results', maxRecords = '25', startPosition = '1')
    return @csw_query_url + ADECswIsoQueryBuilder::get_query_string({
        :resultType => resultType,
        :maxRecords => maxRecords,
        :startPosition => startPosition
    })
  end
end
