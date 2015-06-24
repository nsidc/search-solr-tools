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

      def harvest_eol_into_solr
        eol_dataset_urls.each do |dataset|
          begin
            doc = open_xml_document(dataset)
            if doc.xpath('//xmlns:metadata').size > 1
              # THREDDS allows for a dataset of datasests, EOL should not utilize this
              fail "Complex dataset encountered at #{data_doc.xpath('//xmlns:catalog').to_html}"
            end
            metadata_doc = open_xml_document(doc.xpath('//xmlns:metadata')[0]['xlink:href'])
            insert_doc = [{ 'add' => { 'doc' => @translator.translate(doc, metadata_doc) } }]
            insert_solr_docs insert_doc, Base::JSON_CONTENT_TYPE
          rescue => e
            puts "ERROR: #{e}"
            puts "Failed to translate this record: #{doc} -> #{metadata_doc}"
            raise e if @die_on_failure
          end
        end
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

      def harvest_and_delete
        puts 'Running harvest of EOL endpoints'
        super(method(:harvest_eol_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:EOL][:long_name]}\"")
      end
    end
  end
end
