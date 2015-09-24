module SearchSolrTools
  module Harvesters
    # Harvests data from NODC PALEO and inserts it into Solr after it has been translated
    class NcdcPaleo < Base
      def initialize(env = 'development', die_on_failure = false)
        super env, die_on_failure
        @page_size = 50
        @translator = Helpers::IsoToSolr.new :ncdc_paleo
      end

      def harvest_and_delete
        puts "Running harvest of NCDC Paleo catalog from #{ncdc_paleo_url}"
        super(method(:harvest_ncdc_paleo_into_solr), "data_centers:\"#{Helpers::SolrFormat::DATA_CENTER_NAMES[:NCDC_PALEO][:long_name]}\"")
      end

      def harvest_ncdc_paleo_into_solr
        start_index = 1
        while (entries = get_results_from_ncdc_paleo_url(start_index)) && (entries.length > 0)
          begin
            insert_solr_docs get_docs_with_translated_entries_from_ncdc_paleo(entries)
          rescue => e
            puts "ERROR: #{e}"
            raise e if @die_on_failure
          end
          start_index += @page_size
        end
      end

      def ncdc_paleo_url
        SolrEnvironments[@environment][:ncdc_paleo_url]
      end

      def get_results_from_ncdc_paleo_url(start_index)
        get_results build_csw_request('results', @page_size, start_index), '//csw:Record'
      end

      def get_docs_with_translated_entries_from_ncdc_paleo(entries)
        auth_ids = entries.map { |e| e.xpath("./dc:identifier[@scheme='urn:x-esri:specification:ServiceType:ArcIMS:Metadata:DocID']").text }

        auth_ids.map do |record|
          result_xml = get_results("http://gis.ncdc.noaa.gov/gptpaleo/csw?getxml=#{record}",
                                   '/rdf:RDF/rdf:Description').first
          solr_doc = create_new_solr_add_doc_with_child(@translator.translate(result_xml).root)
          insert_node = solr_doc.at_xpath('//doc')
          insert_node.add_child("<field name='authoritative_id'>#{record}</field>")
          insert_node.add_child("<field name='dataset_url'>http://gis.ncdc.noaa.gov/gptpaleo/catalog/search/resource/details.page?uuid=#{record}")
          solr_doc.root
        end
      end

      def build_csw_request(resultType = 'results', maxRecords = '1000', startPosition = '1')
        Helpers::CswIsoQueryBuilder.get_query_string(ncdc_paleo_url,
                                                     'resultType' => resultType,
                                                     'maxRecords' => maxRecords,
                                                     'startPosition' => startPosition
                                                    )
      end
    end
  end
end
