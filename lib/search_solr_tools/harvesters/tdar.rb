module SearchSolrTools
  module Harvesters
    # Harvests data from TDAR and inserts it into Solr after it has been translated
    class Tdar < Base
      def initialize(env = 'development', die_on_failure = false)
        super env, die_on_failure
        @page_size = 100
        @translator = Helpers::IsoToSolr.new :tdar
      end

      def harvest_and_delete
        puts "Running harvest of TDAR catalog from #{tdar_url}"
        super(method(:harvest_tdar_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:TDAR][:long_name]}\"")
      end

      def harvest_tdar_into_solr
        start_record = 1
        while (entries = get_results_from_tdar(start_record)) && (entries.length > 0)
          begin
            insert_solr_docs get_docs_with_translated_entries_from_tdar(entries)
          rescue => e
            puts "ERROR: #{e}\n\n"
            raise e if @die_on_failure
          end
          start_record += @page_size
        end
      end

      def tdar_url
        SolrEnvironments[@environment][:tdar_url]
      end

      def get_results_from_tdar(start_record)
        get_results build_request(@page_size, start_record), './/atom:entry', 'application/xml'
      end

      def get_docs_with_translated_entries_from_tdar(entries)
        entries.map do |entry|
          create_new_solr_add_doc_with_child(@translator.translate(entry).root)
        end
      end

      def build_request(max_records = '25', start_record = '1')
        request_url = tdar_url + '?_tDAR.searchType=ACADIS_RSS&'\
                                 'resourceTypes=DATASET&'\
                                 'groups[0].latitudeLongitudeBoxes[0].maximumLongitude=180&'\
                                 'groups[0].latitudeLongitudeBoxes[0].minimumLatitude=45&'\
                                 'groups[0].latitudeLongitudeBoxes[0].minimumLongitude=-180&'\
                                 'groups[0].latitudeLongitudeBoxes[0].maximumLatitude=90&'\
                                 'geoMode=ENVELOPE&'\
                                 'recordsPerPage=' + max_records.to_s + '&startRecord=' + start_record.to_s

        request_url
      end
    end
  end
end
