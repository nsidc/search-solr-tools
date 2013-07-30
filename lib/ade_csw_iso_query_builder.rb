# Constructs the string to query GI-Cat for CSW-ISO data
class ADECswIsoQueryBuilder

  # get the query string from a hash of parameters
  class QueryBuilder
    def assemble_query(params)
      '?' + params.map { |k, v| "#{k}=#{v}" }.join('&')
    end
  end

  DEFAULT_PARAMS = {
    service: 'CSW',
    version: '2.0.2',
    request: 'GetRecords',
    'TypeNames' => 'gmd:MD_Metadata',
    namespace: 'xmlns(gmd=http://www.isotc211.org/2005/gmd)',
    'ElementSetName' => 'full',
    'resultType' => 'results',
    'outputFormat' => 'application/xml',
    'maxRecords' => '25',
    'startPosition' => '1',
    'outputSchema' => 'http://www.isotc211.org/2005/gmd'
  }

  def self.get_query_string(query_params = {})
    all_params = query_params(query_params)
    builder = QueryBuilder.new
    builder.assemble_query(all_params)
  end

  def self.query_params(query_params = {})
    DEFAULT_PARAMS.merge(query_params)
  end
end
