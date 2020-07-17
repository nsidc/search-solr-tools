module SearchSolrTools
  module Helpers
    class HarvestStatus

      INGEST_OK = :ok
      HARVEST_NO_DOCS = :harvest_none
      HARVEST_FAILURE = :harvest_fail
      INGEST_ERR_INVALID_DOC = :invalid
      INGEST_ERR_SOLR_ERROR = :solr_error

      ERROR_STATUS = [HARVEST_NO_DOCS, HARVEST_FAILURE, INGEST_ERR_INVALID_DOC, INGEST_ERR_SOLR_ERROR]

      def initialize
        @status = { INGEST_OK => [] }
        ERROR_STATUS.each { |s| @status[s] = [] }
      end

      def record_multiple_document_status(documents, doc_status)
        documents.each { |d| record_document_status d, doc_status }
      end

      def record_document_status(document, doc_status)
        @status[doc_status] << document
      end

      def ok?
        ERROR_STATUS.each { |s| return false unless @status[s].empty? }
        true
      end

      def documents_with_status(doc_status)
        @status[doc_status]
      end
    end
  end
end