require 'search_solr_tools/harvesters/oai'
require 'search_solr_tools/helpers'

module SearchSolrTools
  module Harvesters
    # Harvests data from Polar data catalogue and inserts it into
    # Solr after it has been translated
    class Pdc < Oai
      def initialize(env = 'development', die_on_failure = false)
        super
        @data_centers = Helpers::SolrFormat::DATA_CENTER_NAMES[:PDC][:long_name]
        @translator = Helpers::IsoToSolr.new :pdc
      end

      def metadata_url
        SolrEnvironments[@environment][:pdc_url]
      end

      def results
        list_records_oai_response = get_results(request_string, '//oai:ListRecords', '')

        @resumption_token = list_records_oai_response.xpath('.//oai:resumptionToken', Helpers::IsoNamespaces.namespaces).first.text

        list_records_oai_response.xpath('.//oai:record', Helpers::IsoNamespaces.namespaces)
      end

      private

      def request_params
        # If a 'resumptionToken' is supplied with any arguments other than 'verb',
        # the response from PDC gives a badArgument error, saying "The argument
        # 'resumptionToken' must be supplied without other arguments"
        {
          verb: 'ListRecords',
          metadataPrefix: @resumption_token.nil? ? 'iso' : nil,
          resumptionToken: @resumption_token
        }.delete_if { |_k, v| v.nil? }
      end
    end
  end
end
