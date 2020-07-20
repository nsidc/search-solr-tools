module SearchSolrTools
  module Errors
    class HarvestError < StandardError
      ERRCODE_SOLR_PING = 1
      ERRCODE_SOURCE_PING = 2
      ERRCODE_SOURCE_NO_RESULTS = 4
      ERRCODE_SOURCE_HARVEST_ERROR = 8
      ERRCODE_DOCUMENT_INVALID = 16
      ERRCODE_INGEST_ERROR = 32
      ERRCODE_OTHER = 128

      ERRCODE_DESC = {
          ERRCODE_SOLR_PING => 'Solr instance did not return a successful ping',
          ERRCODE_SOURCE_PING => 'Source to be harvested did not return a successful ping',
          ERRCODE_SOURCE_NO_RESULTS => 'Source to be harvested returned no documents matching query',
          ERRCODE_SOURCE_HARVEST_ERROR => 'One or more source documents returned an error when trying to retrieve or translate',
          ERRCODE_DOCUMENT_INVALID => 'One or more documents to be harvested was invalid (malformed)',
          ERRCODE_INGEST_ERROR => 'Solr returned an error trying to ingest one or more harvested documents',
          ERRCODE_OTHER => 'General error code for non-harvest related issues'
      }.freeze

      def self.describe_exit_code(code)
        code = code.to_i
        code_list = []

        # Loop through all bit-flag values
        [128, 64, 32, 16, 8, 4, 2, 1].each do |k|
          if code >= k
            code_list.prepend k
            code -= k
          end
        end

        codes = {}
        code_list.each do |k|
          codes[k] = ERRCODE_DESC.keys.include?(k) ? ERRCODE_DESC[k] : 'INVALID CODE NUMBER'
        end

        codes
      end

      def initialize(status, message=nil)
        @status_data = status
        @other_message = message
      end

      def exit_code
        if @status_data.nil?
          puts "OTHER ERROR REPORTED: #{@other_message}"
          return ERRCODE_OTHER
        end

        code = 0
        code += ERRCODE_SOLR_PING unless @status_data.ping_solr
        code += ERRCODE_SOURCE_PING unless @status_data.ping_source
        code += ERRCODE_SOURCE_NO_RESULTS if @status_data.documents_with_status(Helpers::HarvestStatus::HARVEST_NO_DOCS).size > 0
        code += ERRCODE_SOURCE_HARVEST_ERROR if @status_data.documents_with_status(Helpers::HarvestStatus::HARVEST_FAILURE).size > 0
        code += ERRCODE_DOCUMENT_INVALID if @status_data.documents_with_status(Helpers::HarvestStatus::INGEST_ERR_INVALID_DOC).size > 0
        code += ERRCODE_INGEST_ERROR if @status_data.documents_with_status(Helpers::HarvestStatus::INGEST_ERR_SOLR_ERROR).size > 0

        code
      end

      def message
        self.class.describe_exit_code(exit_code).map{|c,v| v}.join("\n")
      end
    end
  end
end