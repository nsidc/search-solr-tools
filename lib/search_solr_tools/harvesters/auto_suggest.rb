# frozen_string_literal: true

require_relative 'base'
require 'json'
require 'rest-client'

module SearchSolrTools
  module Harvesters
    # Use the nsidc_oai core to populate the auto_suggest core
    class AutoSuggest < Base
      def initialize(env = 'development', die_on_failure: false)
        super
        @env_settings = SolrEnvironments[@environment] # super sets @environment.
      end

      private

      def harvest(url, fields)
        facet_response = fetch_auto_suggest_facet_data(url, fields)
        add_docs = generate_add_hashes(facet_response, fields)
        add_documents_to_solr(add_docs)
      end

      def standard_add_creator(value, count, field_weight, source)
        count_weight = count <= 1 ? 0.4 : Math.log(count)
        weight = field_weight * count_weight
        [{ 'id' => "#{source}:#{value}", 'text_suggest' => value, 'source' => source, 'weight' => weight }]
      end

      def fetch_auto_suggest_facet_data(url, fields)
        fields.each do |name, _config|
          url += "&facet.field=#{name}"
        end

        serialized_facet_response = RestClient.get url
        JSON.parse(serialized_facet_response)
      end

      def generate_add_hashes(facet_response, fields)
        add_docs = []
        facet_response['facet_counts']['facet_fields'].each do |facet_name, facet_values|
          facet_values.each_slice(2) do |facet_value|
            new_docs = fields[facet_name][:creator].call(facet_value[0], facet_value[1], fields[facet_name][:weight], fields[facet_name][:source])
            add_docs.concat(new_docs)
          end
        end
        add_docs
      end

      def add_documents_to_solr(add_docs)
        status = insert_solr_doc add_docs, Base::JSON_CONTENT_TYPE, @env_settings[:auto_suggest_collection_name]

        if status == Helpers::HarvestStatus::INGEST_OK
          puts "Added #{add_docs.size} auto suggest documents in one commit"
          Helpers::HarvestStatus.new(Helpers::HarvestStatus::INGEST_OK => add_docs)
        else
          puts "Failed adding #{add_docs.size} documents in single commit, retrying one by one"
          new_add_docs = []
          add_docs.each do |doc|
            new_add_docs << { 'add' => { 'doc' => doc } }
          end
          insert_solr_docs new_add_docs, Base::JSON_CONTENT_TYPE, @env_settings[:auto_suggest_collection_name]
        end
      end
    end
  end
end
