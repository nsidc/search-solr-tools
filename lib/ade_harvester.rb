require 'rest-client'
require 'nokogiri'
require 'open-uri'
require './lib/ade_csw_iso_query_builder'
require './lib/iso_to_solr'

# Harvests data from GI-Cat and inserts it into Solr after it has been translated
class ADEHarvester
  ISO_NAMESPACES = { 'gmd' => 'http://www.isotc211.org/2005/gmd',  'gco' => 'http://www.isotc211.org/2005/gco' }

  attr_accessor :environment, :page_size

  def initialize(env = 'development')
    @environment = env
    @page_size = 100
    @translator = IsoToSolr.new :cisl
  end

  def solr_url
    'http://' + SolrEnvironments[@environment][:host] + ':' + SolrEnvironments[@environment][:port] + '/' + SolrEnvironments[@environment][:collection_path]
  end

  # get translated entries from GI-Cat and add them to Solr
  # this is the main entry point for the class
  def harvest_gi_cat_into_solr
    solr_docs = get_doc_with_translated_entries_from_gi_cat
    insert_solr_docs(solr_docs.to_xml)
  end

  # returns Nokogiri XML document with content
  # '<?xml version="1.0"?><root_name/>'
  def create_new_doc_with_root(root_name)
    doc = Nokogiri::XML::Document.new
    doc.root = Nokogiri::XML::Node.new(root_name, doc)
    doc
  end

  # returns a Nokogiri XML document with structure
  # <add> <doc><doc>...<doc> </add>
  # this structure can be POSTed to Solr to update the db
  #
  # each entry from GI-Cat is translated to our Solr format, then
  # inserted into a <doc> element
  def get_doc_with_translated_entries_from_gi_cat
    doc = create_new_doc_with_root 'add'
    start_index = 1
    while (entries = get_results_from_gi_cat(start_index)) && (entries.length > 0)
      entries.each { |entry| doc.root.add_child @translator.translate(entry).root }
      start_index += @page_size
    end
    doc
  end

  # returns a Nokogiri NodeSet containing @page_size search results from GI-Cat
  def get_results_from_gi_cat(start_index)
    query_string = build_csw_request('results', @page_size, start_index)
    results = Nokogiri.XML(open(query_string))
    results.xpath('//gmd:MD_Metadata', ISO_NAMESPACES)
  end

  # Update Solr with a set of documents
  def insert_solr_docs(docs)
    url = solr_url + '/update?commit=true'
    RestClient.post(url,
                    docs,
                    { content_type: 'text/xml; charset=utf-8' }) { |response, request, result| response.code }
  end

  def csw_query_url
    SolrEnvironments[@environment][:gi_cat_csw_url]
  end

  def build_csw_request(resultType = 'results', maxRecords = '25', startPosition = '1')
    csw_query_url + ADECswIsoQueryBuilder.get_query_string({
        'resultType' => resultType,
        'maxRecords' => maxRecords,
        'startPosition' => startPosition
    })
  end
end
