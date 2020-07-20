module SearchSolrTools
  module Helpers
    class HarvestStatus

      INGEST_OK = :ok
      HARVEST_NO_DOCS = :harvest_none
      HARVEST_FAILURE = :harvest_fail
      INGEST_ERR_INVALID_DOC = :invalid
      INGEST_ERR_SOLR_ERROR = :solr_error
      OTHER_ERROR = :other

      ERROR_STATUS = [HARVEST_NO_DOCS, HARVEST_FAILURE, INGEST_ERR_INVALID_DOC, INGEST_ERR_SOLR_ERROR, OTHER_ERROR]

      def initialize
        @status = { INGEST_OK => [] }
        @ping_solr = true
        @ping_source = true
        ERROR_STATUS.each { |s| @status[s] = [] }
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