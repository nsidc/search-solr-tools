require_relative 'base'
require 'json'
require 'rgeo/geo_json'
require 'pry-byebug'

module SearchSolrTools
  module Harvesters
    class Eol < Base
      def initialize(env = 'development', die_on_failure = false)
        super env, die_on_failure
        @translator = SearchSolrTools::Translators::EolToSolr.new
      end

      def harvest_eol_into_solr
        record = 1
        eol_dataset_urls.each do |dataset|
          begin
            doc = open_xml_document(dataset)
            if doc.xpath('//xmlns:metadata').size > 1
              fail "Complex dataset encountered at #{data_doc.xpath('//xmlns:catalog').to_html}"
            end
            metadata_doc = open_xml_document(doc.xpath('//xmlns:metadata')[0]['xlink:href'])
            insert_doc = [{ 'add' => { 'doc' => @translator.translate(doc, metadata_doc) } }]
            binding.pry
            insert_solr_docs insert_doc, Base::JSON_CONTENT_TYPE
            puts "Inserted record #{record}"
            record += 1
          rescue => e
            puts "ERROR: #{e}"
            puts "Failed to translate this record: #{doc} -> #{metadata_doc}"
            raise e if @die_on_failure
          end
        end
      end

      def eol_dataset_urls
        results = []
        eol_endpoints.each do |endpoint|
          doc = open_xml_document(endpoint)
          doc.xpath('//xmlns:catalogRef').each { |node| results.push(node['xlink:href']) }
        end
        results
      end

      def eol_endpoints
        %w(
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.SHEBA.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.SBI.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.PacMARS.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.BASE.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.ATLAS.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.ARC_MIP.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.AMTS.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.BOREAS.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.BeringSea.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.ARCSS.thredds.xml
          http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.project.BEST.thredds.xml
        )
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
