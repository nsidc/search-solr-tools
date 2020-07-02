require_relative 'base'
require 'json'
require 'rest-client'

module SearchSolrTools
  module Harvesters
    # Harvests data from GTN-P endpoints, translates and adds it to solr
    class GtnP < Base
      def initialize(env = 'development', die_on_failure = false)
        super env, die_on_failure
        @translator = Translators::GtnpJsonToSolr.new
      end

      def gtnp_service_urls
        json_records = []
        SearchSolrTools::SolrEnvironments[:common][:gtnp].flat_map do |endpoint|
          record = request_json(endpoint)
          json_records << record
        end
        json_records
      end

      def harvest_and_delete
        puts 'Running harvest of GTN-P catalog using the following configured GTN-P URLs:'
        SearchSolrTools::SolrEnvironments[:common][:gtnp].each { |x| puts x }
        super(method(:harvest_gtnp_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:GTNP][:long_name]}\"")
      end

      def harvest_gtnp_into_solr
        result = translate_gtnp
        insert_solr_docs result[:add_docs], Base::JSON_CONTENT_TYPE
        fail 'Failed to harvest some records from the provider' if result[:failure_ids].length > 0
      end

      def translate_gtnp
        documents = []
        failure_ids = []
        gtnp_records = gtnp_service_urls
        gtnp_records.each do |record|
          results = parse_record(record)
          results[:documents].each { |d| documents << d }
          results[:failure_ids].each { |id| failure_ids << id }
        end
        { add_docs: documents, failure_ids: failure_ids }
      end

      def request_json(url)
        JSON.parse(RestClient.get(url))
      end

      def parse_record(record)
        documents = []
        failure_ids = []
        begin
          record.drop(1).each do |dataset|
            trans_doc = @translator.translate(dataset, record[0])
            documents << { 'add' => { 'doc' => trans_doc } }
          end
        rescue => e
          puts "Failed to add record #{record[0][:title]} with error #{e} (#{e.message}) : #{e.backtrace.join("\n")}"
          failure_ids << record[0][:title]
        end
        { documents: documents, failure_ids: failure_ids }
      end
    end
  end
end
