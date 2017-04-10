module SearchSolrTools
  module Harvesters
    # Harvests data from ECHO and inserts it into Solr after it has been translated
    class Echo < Base
      def initialize(env = 'development', die_on_failure = false)
        super env, die_on_failure
        @page_size = 100
        @translator = Helpers::IsoToSolr.new :echo
      end

      def harvest_and_delete
        puts "Running harvest of ECHO catalog from #{echo_url}"
        super(method(:harvest_echo_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:ECHO][:long_name]}\"")
      end

      # get translated entries from ECHO and add them to Solr
      # this is the main entry point for the class
      def harvest_echo_into_solr
        page_num = 1
        while (entries = get_results_from_echo(page_num)) && (entries.length > 0)
          begin
            insert_solr_docs get_docs_with_translated_entries_from_echo(entries)
          rescue => e
            puts "ERROR: #{e}\n\n"
            raise e if @die_on_failure
          end
          page_num += 1
        end
      end

      def echo_url
        SolrEnvironments[@environment][:echo_url]
      end

      def get_results_from_echo(page_num)
        get_results build_request(@page_size, page_num), './/results/result', 'application/echo10+xml'
      end

      def get_docs_with_translated_entries_from_echo(entries)
        entries.map do |entry|
          create_new_solr_add_doc_with_child(@translator.translate(entry).root)
        end
      end

      def build_request(max_records = '25', page_num = '1')
        echo_url + '&page_size=' + max_records.to_s + '&page_num=' + page_num.to_s
      end
    end
  end
end
