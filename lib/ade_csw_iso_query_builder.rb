class ADECswIsoQueryBuilder

  class QueryBuilder
    def assemble_query(params)
      return "?" + params.collect{ |k, v| "#{k}=#{v}" }.join("&")
    end
  end

  def self.get_query_string( query_params={} )
    all_params = query_params(query_params)
    builder = QueryBuilder.new()
    return builder.assemble_query(all_params)
  end

  def self.query_params( query_params={} )
    {
      :service => 'CSW',
      :version => '2.0.2',
      :request => 'GetRecords',
      :TypeNames => 'gmd:MD_Metadata',
      :namespace => 'xmlns(gmd=http://www.isotc211.org/2005/gmd)',
      :ElementSetName => 'full',
      :resultType => 'results',
      :outputFormat => 'application/xml',
      :maxRecords => '25',
      :startPosition => '1',
      :outputSchema => 'http://www.isotc211.org/2005/gmd'
    }.merge(query_params)
  end
end
