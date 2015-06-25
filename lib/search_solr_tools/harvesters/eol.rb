require_relative 'base'
require 'json'
require 'rgeo/geo_json'

module SearchSolrTools
  module Harvesters
    class Eol < Base
      def initialize(env = 'development', die_on_failure = false)
        super env, die_on_failure
        @translator = SearchSolrTools::Translators::EolToSolr.new
      end

      def harvest_and_delete
        puts 'Running harvest of EOL catalog using the following configured EOL URLs:'
        SearchSolrTools::SolrEnvironments[:common][:eol].each { |x| puts x }
        super(method(:harvest_eol_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:EOL][:long_name]}\"")
      end

      def harvest_eol_into_solr
        solr_add_queries = eol_dataset_urls.map do |dataset|
          begin
            doc = open_xml_document(dataset)
            if doc.xpath('//xmlns:metadata').size > 1
              # THREDDS allows for a dataset of datasests, EOL should not utilize this
              fail "Complex dataset encountered at #{doc.xpath('//xmlns:catalog').to_html}"
            end
            metadata_doc = open_xml_document(doc.xpath('//xmlns:metadata')[0]['xlink:href'])
            { 'add' => { 'doc' => @translator.translate(doc, metadata_doc) } }
          rescue => e
            puts "ERROR: #{e}"
            puts "Failed to translate this record: #{doc} -> #{metadata_doc}"
            raise e if @die_on_failure
            next
          end
        end
        insert_solr_docs solr_add_queries, Base::JSON_CONTENT_TYPE
      end

      def eol_dataset_urls
        results = []
        SearchSolrTools::SolrEnvironments[:common][:eol].each do |endpoint|
          doc = open_xml_document(endpoint)
          doc.xpath('//xmlns:catalogRef').each { |node| results.push(node['xlink:href']) }
        end
        results
      end

      def open_xml_document(url)
        doc = Nokogiri::XML(open(url)) do |config|
          config.strict
        end
        doc
      end
    end
  end
end
