# frozen_string_literal: true

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
        ERRCODE_SOLR_PING            => 'Solr instance did not return a successful ping',
        ERRCODE_SOURCE_PING          => 'Source to be harvested did not return a successful ping',
        ERRCODE_SOURCE_NO_RESULTS    => 'Source to be harvested returned no documents matching query',
        ERRCODE_SOURCE_HARVEST_ERROR => 'One or more source documents returned an error when trying to retrieve or translate',
        ERRCODE_DOCUMENT_INVALID     => 'One or more documents to be harvested was invalid (malformed)',
        ERRCODE_INGEST_ERROR         => 'Solr returned an error trying to ingest one or more harvested documents',
        ERRCODE_OTHER                => 'General error code for non-harvest related issues'
      }.freeze

      PING_ERRCODE_MAP = {
        'ping_solr'   => ERRCODE_SOLR_PING,
        'ping_source' => ERRCODE_SOURCE_PING
      }.freeze

      STATUS_ERRCODE_MAP = {
        Helpers::HarvestStatus::HARVEST_NO_DOCS        => ERRCODE_SOURCE_NO_RESULTS,
        Helpers::HarvestStatus::HARVEST_FAILURE        => ERRCODE_SOURCE_HARVEST_ERROR,
        Helpers::HarvestStatus::INGEST_ERR_INVALID_DOC => ERRCODE_DOCUMENT_INVALID,
        Helpers::HarvestStatus::INGEST_ERR_SOLR_ERROR  => ERRCODE_INGEST_ERROR,
        Helpers::HarvestStatus::OTHER_ERROR            => ERRCODE_OTHER
      }.freeze

      # If code is -1, it means display all error codes
      def self.describe_exit_code(code = -1)
        code_list = code_to_list(code)

        codes = {}
        code_list.each do |k|
          next if code == -1 && !ERRCODE_DESC.keys.include?(k) # skip INVALID CODE if showing all codes

          codes[k] = ERRCODE_DESC.keys.include?(k) ? ERRCODE_DESC[k] : 'INVALID CODE NUMBER'
        end

        codes
      end

      # Loop through all bit-flag values to produce a list of integers
      def self.code_to_list(code)
        code = code.to_i
        code_list = []

        [128, 64, 32, 16, 8, 4, 2, 1].each do |k|
          if code >= k || code == -1
            code_list.prepend k
            code -= k unless code == -1
          end
        end

        code_list
      end

      def initialize(status, message = nil)
        @status_data = status
        @other_message = message

        super message
      end

      # rubocop:disable Metrics/AbcSize
      def exit_code
        if @status_data.nil?
          puts "OTHER ERROR REPORTED: #{@other_message}"
          return ERRCODE_OTHER
        end

        puts "EXIT CODE STATUS:\n#{@status_data.status}"

        code = 0
        code += ERRCODE_SOLR_PING unless @status_data.ping_solr
        code += ERRCODE_SOURCE_PING unless @status_data.ping_source
        code += ERRCODE_SOURCE_NO_RESULTS if @status_data.status[Helpers::HarvestStatus::HARVEST_NO_DOCS].positive?
        code += ERRCODE_SOURCE_HARVEST_ERROR if @status_data.status[Helpers::HarvestStatus::HARVEST_FAILURE].positive?
        code += ERRCODE_DOCUMENT_INVALID if @status_data.status[Helpers::HarvestStatus::INGEST_ERR_INVALID_DOC].positive?
        code += ERRCODE_INGEST_ERROR if @status_data.status[Helpers::HarvestStatus::INGEST_ERR_SOLR_ERROR].positive?

        code = ERRCODE_OTHER if code.zero?

        code
      end
      # rubocop:enable Metrics/AbcSize

      def message
        self.class.describe_exit_code(exit_code).map { |_c, v| v }.join("\n")
      end
    end
  end
end
