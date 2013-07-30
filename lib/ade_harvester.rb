require 'rest-client'
require 'nokogiri'
require 'open-uri'
require './lib/ade_csw_iso_query_builder'
require './lib/ade_iso_to_solr'

# Harvests data from GI-Cat and inserts it into Solr after it has been translated
class ADEHarvester
  ISO_NAMESPACES = { 'gmd' => 'http://www.isotc211.org/2005/gmd',  'gco' => 'http://www.isotc211.org/2005/gco' }

  attr_accessor :environment, :gi_cat_url, :start_index, :page_size

  def initialize(env = 'development')
    @environment = env
    @csw_query_url = SolrEnvironments[@environment][:gi_cat_csw_url]
    @solr_url = 'http://' + SolrEnvironments[@environment][:host] + ':' + SolrEnvironments[@environment][:port] + '/' + SolrEnvironments[@environment][:collection_path]
    @start_index = 1
    @page_size = 100
    @translator = ADEIsoToSolr.new :cisl
  end

  def get_number_of_records
    query_string = build_csw_request('hits', '1', '1')
    results_count = Nokogiri.XML(open(query_string)).xpath('//csw:SearchResults').first['numberOfRecordsMatched']
    results_count.to_i
  end

  def build_xml_to_post_to_solr
    solr_docs_builder = Nokogiri::XML::Builder.new do |xml|
      xml.add
    end
    solr_docs = solr_docs_builder.doc
    add_translated_entries_from_gi_cat_to_doc solr_docs
    solr_docs
  end

  def add_translated_entries_from_gi_cat_to_doc(doc, num_records = get_number_of_records)
    while @start_index - 1 < num_records
      results = get_results_from_gi_cat
      entries = results.xpath('.//gmd:MD_Metadata', ISO_NAMESPACES)
      entries.each { |entry| doc.root.add_child @translator.translate(entry).root }
      @start_index += @page_size
    end
  end

  def get_results_from_gi_cat
    query_string = build_csw_request('results', @page_size, @start_index)
    Nokogiri.XML(open(query_string))
  end

  # Update Solr with a set of documents
  def insert_solr_docs(docs)
    url = @solr_url + '/update?commit=true'

    RestClient.post(url,
                    docs,
                    { content_type: 'text/xml; charset=utf-8' }) { |response, request, result| response.code }
  end

  def harvest
    solr_docs = build_xml_to_post_to_solr
    insert_solr_docs solr_docs.to_xml
  end

  def build_csw_request(resultType = 'results', maxRecords = '25', startPosition = '1')
    @csw_query_url + ADECswIsoQueryBuilder.get_query_string({
        'resultType' => resultType,
        'maxRecords' => maxRecords,
        'startPosition' => startPosition
    })
  end
end
