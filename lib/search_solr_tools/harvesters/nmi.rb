module SearchSolrTools
  module Harvesters
    class Nmi < Oai
      def initialize(env = 'development', die_on_failure = false)
        super
        @data_centers = Helpers::SolrFormat::DATA_CENTER_NAMES[:NMI][:long_name]
        @translator = Helpers::IsoToSolr.new :nmi
      end

      def metadata_url
        SolrEnvironments[@environment][:nmi_url]
      end

      # resumption_token must be empty to stop the harvest loop; NMI's feed does not
      # provide any resumption token and gets all the records in just one go
      def results
        @resumption_token = ''
        list_records_oai_response = get_results(request_string, '//oai:ListRecords', '')
        list_records_oai_response.xpath('.//oai:record', Helpers::IsoNamespaces.namespaces)
      end

      private

      def request_params
        {
          verb: 'ListRecords',
          metadataPrefix: 'dif'
        }
      end
    end
  end
end
