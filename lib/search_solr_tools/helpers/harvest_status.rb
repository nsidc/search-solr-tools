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

      def record_multiple_document_status(documents, doc_status)
        documents.each { |d| record_document_status d, doc_status }
      end

      def record_document_status(document, doc_status)
        @status[doc_status] << document
      end

      def ping_solr=(newval)
        @ping_solr = newval
      end

      def ping_source=(newval)
        @ping_source = newval
      end

      def ok?
        ERROR_STATUS.each { |s| return false unless @status[s].empty? }
        @ping_solr && @ping_source
      end

      def ping_solr
        @ping_solr
      end

      def ping_source
        @ping_source
      end

      def documents_with_status(doc_status)
        @status[doc_status]
      end
    end
  end
end