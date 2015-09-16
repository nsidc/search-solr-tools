module SearchSolrTools
  module Harvesters
    class DataOne < Base
      def initialize(env = 'development', die_on_failure = false)
        super
        @page_size = 250
        @translator = Helpers::IsoToSolr.new :data_one
      end

      def harvest_and_delete
        puts "Running harvest of dataONE catalog from #{metadata_url}"
        super(method(:harvest_data_one_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:DATA_ONE][:long_name]}\"")
      end

      def harvest_data_one_into_solr
        start = 0
        while (entries = get_results_from_data_one(start)) && (entries.length > 0)
          begin
            insert_solr_docs(get_docs_with_translated_entries_from_data_one(entries))
          rescue => e
            puts "ERROR: #{e}\n\n"
            raise e if @die_on_failure
          end
          start += @page_size
        end
      end

      def get_results_from_data_one(start)
        get_results(build_request(start, @page_size), './response/result/doc')
      end

      def metadata_url
        SolrEnvironments[@environment][:data_one_url]
      end

      def get_docs_with_translated_entries_from_data_one(entries)
        entries.map do |e|
          create_new_solr_add_doc_with_child(@translator.translate(e).root)
        end
      end

      def build_request(start = 0, max_records = 100)
        "#{metadata_url}&start=#{start}&rows=#{max_records}"
      end
    end
  end
end
