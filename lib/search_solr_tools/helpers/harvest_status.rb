module SearchSolrTools
  module Helpers
    class HarvestStatus
      INGEST_OK = :ok
      HARVEST_NO_DOCS = :harvest_none
      HARVEST_FAILURE = :harvest_fail
      INGEST_ERR_INVALID_DOC = :invalid
      INGEST_ERR_SOLR_ERROR = :solr_error
      OTHER_ERROR = :other
      PING_SOLR = :ping_solr  # used for initialize only
      PING_SOURCE = :ping_source  # used for initialize only

      ERROR_STATUS = [HARVEST_NO_DOCS, HARVEST_FAILURE, INGEST_ERR_INVALID_DOC, INGEST_ERR_SOLR_ERROR, OTHER_ERROR]

      attr_reader :status, :ping_solr, :ping_source
      attr_writer :ping_solr, :ping_source

      # init_info is an optional hash that contains the various status keys and the documents to
      # associate with them
      def initialize(init_info={})
        @status = { INGEST_OK => [] }
        @ping_solr = true
        @ping_source = true
        ERROR_STATUS.each { |s| @status[s] = [] }

        init_info.each do |key, docs|
          @status[key] = docs if @status.include? key
        end

        @ping_solr = init_info[PING_SOLR] if init_info.include? PING_SOLR
        @ping_source = init_info[PING_SOURCE] if init_info.include? PING_SOURCE
      end

      def record_status(status, message='')
        @status[status] << message
      end

      def record_status_multiple(doc_status, messages=[])
        messages.each { |m| record_status doc_status, m }
      end

      def ok?
        ERROR_STATUS.each { |s| return false unless @status[s].empty? }
        @ping_solr && @ping_source
      end
    end
  end
end