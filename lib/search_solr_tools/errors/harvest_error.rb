module SearchSolrTools
  module Errors
    class HarvestError < StandardError
      def initialize(status)
        @status_data = status
      end

      def message
        "Errors during harvesting"
      end
    end
  end
end