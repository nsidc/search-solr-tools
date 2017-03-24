module SearchSolrTools
  module Harvesters
    class Cisl < Base
      def initialize(env = 'development', die_on_failure = false)
        super
        @page_size = 250
        @translator = Helpers::IsoToSolr.new :cisl
      end

      def harvest_and_delete
        puts "Running harvest of cisl catalog from #{metadata_url}"
        super(method(:harvest_cisl_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:CISL][:long_name]}\"")
      end

      def harvest_cisl_into_solr
        start = 0
        while (entries = get_results_from_cisl(start)) && (entries.length > 0)
          begin
            insert_solr_docs(get_docs_with_translated_entries_from_cisl(entries))
          rescue => e
            puts "ERROR: #{e}\n\n"
            raise e if @die_on_failure
          end
          start += @page_size
        end
      end

      def get_results_from_cisl(start)
        get_results(build_request(start, @page_size), './response/result/doc')
      end

      def metadata_url
        SolrEnvironments[@environment][:cisl_url]
      end

      def get_docs_with_translated_entries_from_cisl(entries)
        entries.map do |e|
          create_new_solr_add_doc_with_child(@translator.translate(e).root)
        end
      end

      def build_request(start = 0, max_records = 100)
        "#{metadata_url}?q=*:*&start=#{start}&rows=#{max_records}"
      end
    end
  end
end
