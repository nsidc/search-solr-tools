module SearchSolrTools
  module Helpers
    # Class to build a query string based on a hash of params
    class QueryBuilder
      class << self
        def build(params)
          param_str = params.map { |k, v| "#{k}=#{v}" }.join('&')
          "?#{param_str}"
        end
      end
    end
  end
end
