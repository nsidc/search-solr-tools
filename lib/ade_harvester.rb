require 'ade_csw_iso_query_builder'
require 'nokogiri'
require 'open-uri'
require 'rsolr'

class ADEHarvester
  attr_accessor :environment, :gi_cat_url

  def initialize( env="integration" )
    @environment = env
    @csw_query_url = SolrEnvironments[@environment][:gi_cat_csw_url]
    @solr_url = "http://" + SolrEnvironments[@environment][:host] + ":" + SolrEnvironments[@environment][:port] + "/" + SolrEnvironments[@environment][:collection_path]
  end

  def getNumberOfRecords
    queryString = buildCswRequest("hits", "1", "1")
    resultsCount = Nokogiri::XML(open(queryString)).xpath("//csw:SearchResults").first['numberOfRecordsMatched']

    return resultsCount.to_i
  end

  def getRecords pageSize, startIndex
    queryString = buildCswRequest("results", pageSize, startIndex)

    return Nokogiri::XML(open(queryString))
  end

  def transformCswToSolrDoc(cswResponseXml)
    #TODO: Placeholder method to convert the GI-Cat response into a Solr doc
    datasets = cswResponseXml.xpath(".//gmd:MD_Metadata")
    jsonDocs = []

    for dataset in datasets
      jsonDocs.push(doc)
    end

    return jsonDocs
  end

  # Update Solr with a set of documents
  def insertSolrDocs solrDocs
    #TODO: Make this method work using RSolr
    # solr = RSolr.connect :url => @solr_url
    # solr.add solrDocsJson, :add_attributes => {:allowDups => false}
  end

  def harvest
    startIndex = 1
    pageSize = 25

    while startIndex - 1 < getNumberOfRecords
      # This is the old code we used
      # result_query_url = env[:gi_cat_csw_url] + "?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=#{pageSize}&startPosition=#{startIndex}&outputSchema=http://www.isotc211.org/2005/gmd"
      # sh "curl -s '#{result_query_url}' | xsltproc ./ade_oai_iso.xslt - > ade_oai_output.xml"
      # sh "curl -a 'http://#{env[:host]}:#{env[:port]}/solr/update?commit=true' -H 'Content-Type: text/xml; charset=utf-8' --data-binary @ade_oai_output.xml"

      resultsXml = getRecords(pageSize, startIndex)

      solrDocs = transformCswToSolrDoc(resultsXml)

      insertSolrDocs(solrDocs)

      startIndex += pageSize
    end
  end

  def buildCswRequest(resultType = 'results', maxRecords = '25', startPosition = '1')
    return @csw_query_url + ADECswIsoQueryBuilder::get_query_string({
        :resultType => resultType,
        :maxRecords => maxRecords,
        :startPosition => startPosition
    })
  end
end
