require 'json'
require 'rest-client'

require 'search_solr_tools'

module SearchSolrTools
  module Harvesters
    # Harvests data from NSIDC OAI and inserts it into Solr after it has been translated
    class NsidcJson < Base
      def initialize(env = 'development', die_on_failure = false)
        super env, die_on_failure
        @translator = Translators::NsidcJsonToSolr.new
        Helpers::FacetConfiguration.import_bin_configuration(env)
      end

      def ping_source
        begin
          RestClient.options(nsidc_json_url) do |response, _request, _result|
            return response.code == 200
          end
        rescue => e
          puts "Error trying to get options for #{nsidc_json_url} (ping)"
        end
        false
      end

      def harvest_and_delete
        puts "Running harvest of NSIDC catalog from #{nsidc_json_url}"
        super(method(:harvest_nsidc_json_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:NSIDC][:long_name]}\"")
      end

      # get translated entries from NSIDC OAI and add them to Solr
      # this is the main entry point for the class
      def harvest_nsidc_json_into_solr
        result = docs_with_translated_entries_from_nsidc

        # TODO:  need to catch possible fail from insert_solr_docs?
        insert_solr_docs result[:add_docs], Base::JSON_CONTENT_TYPE
        fail 'Failed to harvest and insert some authoritative IDs' if result[:failure_ids].length > 0
      end

      def nsidc_json_url
        SolrEnvironments[@environment][:nsidc_dataset_metadata_url]
      end

      # TODO First ping the nsidc_oai_identifiers_url (DCS) to make sure it's responsive.
      #  If it's not, return error and exit the job with a non-zero status.
      def result_ids_from_nsidc
        url = SolrEnvironments[@environment][:nsidc_dataset_metadata_url] +
              SolrEnvironments[@environment][:nsidc_oai_identifiers_url]
        get_results url, '//xmlns:identifier'
      end

      # Fetch a JSON representation of a dataset's metadata
      # @param id [String] NSIDC authoritative ID for the dataset
      # @return [Hash] Parsed version of the JSON response
      def fetch_json_from_nsidc(id)
        json_response = RestClient.get(nsidc_json_url + id + '.json')
        JSON.parse(json_response)
      end

      def docs_with_translated_entries_from_nsidc
        docs = []
        failure_ids = []

        result_ids_from_nsidc.each do |r|
          # Each result looks like:
          # oai:nsidc.org/AE_L2A
          id = r.text.split('/').last
          begin
            docs << { 'add' => { 'doc' => @translator.translate(fetch_json_from_nsidc(id)) } }
          rescue => e
            puts "Failed to fetch #{id} with error #{e}: #{e.backtrace}"
            failure_ids << id
          end
        end

        { add_docs: docs, failure_ids: failure_ids }
      end
    end
  end
end
