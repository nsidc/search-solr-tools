require 'search_solr_tools/helpers/query_builder'

module SearchSolrTools
  module Helpers
    # Constructs the string to query a CSW endpoint
    class CswIsoQueryBuilder
      DEFAULT_PARAMS = {
        service: 'CSW',
        version: '2.0.2',
        request: 'GetRecords',
        'TypeNames' => 'gmd:MD_Metadata',
        'ElementSetName' => 'full',
        'resultType' => 'results',
        'outputFormat' => 'application/xml',
        'maxRecords' => '25',
        'startPosition' => '1',
        'outputSchema' => 'http://www.isotc211.org/2005/gmd'
      }

      def self.get_query_string(url, query_params = {})
        all_params = query_params(query_params)
        QueryBuilder.build(all_params).prepend(url)
      end

      def self.query_params(query_params = {})
        DEFAULT_PARAMS.merge(query_params)
      end
    end
  end
end
