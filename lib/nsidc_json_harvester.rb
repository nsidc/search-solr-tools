require 'nokogiri'
require 'rest-client'
require './lib/harvester_base'
require './lib/nsidc_json_to_solr'
require 'json'
require 'parallel'

# Harvests data from NSIDC OAI and inserts it into Solr after it has been translated
class NsidcJsonHarvester < HarvesterBase
  def initialize(env = 'development')
    super env
    @translator = NsidcJsonToSolr.new
  end

  # get translated entries from NSIDC OAI and add them to Solr
  # this is the main entry point for the class
  def harvest_nsidc_json_into_solr
    result = docs_with_translated_entries_from_nsidc
    insert_solr_docs result[:add_docs], HarvesterBase::JSON_CONTENT_TYPE
    fail 'Failed to harvest and insert some authoritative IDs' if result[:failure_ids].length > 0
  end

  def result_ids_from_nsidc
    get_results SolrEnvironments[@environment][:nsidc_oai_identifiers_url], '//xmlns:identifier'
  end

  def fetch_json_from_nsidc(id)
    json_response = RestClient.get(SolrEnvironments[@environment][:nsidc_dataset_metadata_url] + id + '.json')
    JSON.parse(json_response)
  end

  def docs_with_translated_entries_from_nsidc(processes = 3)
    docs = []
    failure_ids = []

    Parallel.each(result_ids_from_nsidc, in_processes: processes) do |r|
      id = r.text.split('/').last
      begin
        docs << { 'add' => { 'doc' => @translator.translate(fetch_json_from_nsidc(id)) } }
      rescue => e
        puts "Failed to fetch #{id} with error: #{e}"
        failure_ids << id
      end
    end

    { add_docs: docs, failure_ids: failure_ids }
  end
end
