require 'nokogiri'
require 'rest-client'
require './lib/harvester_base'
require './lib/nsidc_json_to_solr'

# Harvests data from NSIDC OAI and inserts it into Solr after it has been translated
class NsidcJsonHarvester < HarvesterBase
  def initialize(env = 'development')
    super env
    @translator = NsidcJsonToSolr.new
  end

  # get translated entries from NSIDC OAI and add them to Solr
  # this is the main entry point for the class
  def harvest_nsidc_json_into_solr
    insert_solr_docs docs_with_translated_entries_from_nsidc, HarvesterBase::JSON_CONTENT_TYPE
  end

  def result_ids_from_nsidc
    get_results SolrEnvironments[@environment][:nsidc_oai_identifiers_url], '//xmlns:identifier'
  end

  def fetch_json_from_nsidc(oai_id)
    id = oai_id.split('/').last
    json_response = RestClient.get(SolrEnvironments[@environment][:nsidc_dataset_metadata_url] + id + '.json')
    JSON.parse(json_response)
  end

  def docs_with_translated_entries_from_nsidc
    docs = []

    result_ids_from_nsidc.each do |r|
      docs << { 'add' => { 'doc' => @translator.translate(fetch_json_from_nsidc(r.text)) } }
    end

    docs
  end
end
