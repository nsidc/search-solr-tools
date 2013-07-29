require 'rest-client'
require 'nokogiri'
require 'open-uri'
require './lib/ade_csw_iso_query_builder'

class ADEHarvester
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

  def getRecords
    startIndex = 1
    pageSize = 100
    numRecords = getNumberOfRecords

    records = Nokogiri::XML::Builder.new do |xml|
      xml.root {
        # Grab each page of results
        #while startIndex - 1 < numRecords
          results = getResults(pageSize, startIndex)

          entries = results.xpath(".//gmd:MD_Metadata")

          entries.each do |entry|
            xml.doc_ entry
          end

          startIndex += pageSize
        #end
      }
    end

    return records.to_xml
  end

  def getResults pageSize, startIndex
    queryString = buildCswRequest("results", pageSize, startIndex)
    return Nokogiri::XML(open(queryString))
  end

  def transformCswToSolrDoc(cswResponseXml)
    return cswResponseXml
  end

  # Update Solr with a set of documents
  def insertSolrDocs solrDocs
    RestClient.post(@solr_url + "/update?commit=true",
                    solrDocs,
                    {:Content_Type => 'text/xml; charset=utf-8'}) { |response, request, result| return response.code }
  end

  def harvest
      resultsXml = getRecords

      solrDocs = transformCswToSolrDoc(resultsXml)

      solrDocs = buildAddXMLMessage solrDocs

      insertSolrDocs(solrDocs)
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
