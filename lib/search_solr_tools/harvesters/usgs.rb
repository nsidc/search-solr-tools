require_relative 'base'
require_relative '../helpers/csw_iso_query_builder'

module SearchSolrTools
  module Harvesters
    # Harvests data from USGS and inserts it into Solr after it has been translated
    class Usgs < Base
      def initialize(env = 'development', die_on_failure = false)
        super env, die_on_failure
        @page_size = 100
        @translator = Helpers::IsoToSolr.new :usgs
      end

      def harvest_and_delete
        puts "Running harvest of USGS catalog from #{usgs_url}"
        super(method(:harvest_usgs_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:USGS][:long_name]}\"")
      end

      # get translated entries from USGS and add them to Solr
      # this is the main entry point for the class
      def harvest_usgs_into_solr
        start_index = 1
        while (entries = get_results_from_usgs(start_index)) && (entries.length > 0)
          begin
            insert_solr_docs get_docs_with_translated_entries_from_usgs(entries)
          rescue => e
            puts "ERROR: #{e}"
            raise e if @die_on_failure
          end
          start_index += @page_size
        end
      end

      def usgs_url
        SolrEnvironments[@environment][:usgs_url]
      end

      def get_results_from_usgs(start_index)
        get_results build_csw_request('results', @page_size, start_index), '//gmd:MD_Metadata', ''
      end

      def get_docs_with_translated_entries_from_usgs(entries)
        entries.map do |entry|
          create_new_solr_add_doc_with_child(@translator.translate(entry).root)
        end
      end

      def build_csw_request(resultType = 'results', maxRecords = '25', startPosition = '1')
        Helpers::CswIsoQueryBuilder.get_query_string(usgs_url,
                                                     'resultType' => resultType,
                                                     'maxRecords' => maxRecords,
                                                     'startPosition' => startPosition,
                                                     'TypeNames' => '',
                                                     'constraint' => bbox_constraint,
                                                     'outputSchema' => 'http://www.isotc211.org/2005/gmd')
      end

      def bbox_constraint
        bbox = {
          west: '-180',
          south: '45',
          east: '180',
          north: '90'
        }

        URI.encode '<Filter xmlns:ogc="http://www.opengis.net/ogc" ' \
                   'xmlns:gml="http://www.opengis.net/gml" ' \
                   'xmlns:apiso="http://www.opengis.net/cat/csw/apiso/1.0">' \
                   '<ogc:BBOX><PropertyName>apiso:BoundingBox</PropertyName><gml:Envelope>' \
                   '<gml:lowerCorner>' + bbox[:west] + ' ' + bbox[:south] + '</gml:lowerCorner>' \
                                                                            '<gml:upperCorner>' + bbox[:east] + ' ' + bbox[:north] + '</gml:upperCorner>' \
                                                                                                                                     '</gml:Envelope></ogc:BBOX></Filter>'
      end
    end
  end
end
