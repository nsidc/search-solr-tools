require_relative './oai_harvester'
require_relative './selectors/helpers/iso_namespaces'
require_relative './selectors/helpers/iso_to_solr'

# Harvests the RDA feed
class RdaHarvester < OaiHarvester
  def initialize(env = 'development', die_on_failure = false)
    super
    @data_centers = SolrFormat::DATA_CENTER_NAMES[:RDA][:long_name]
    @translator = IsoToSolr.new :rda
  end

  def metadata_url
    SolrEnvironments[@environment][:rda_url]
  end

  # resumption_token must be empty to stop the harvest loop; RDA's feed does not
  # provide any resumption token and gets all the records in just one go
  def results
    @resumption_token = ''
    list_records_oai_response = get_results(request_string, '//oai:ListRecords', '')
    list_records_oai_response.xpath('.//oai:record', IsoNamespaces.namespaces)
  end

  private

  def request_params
    {
      verb: 'ListRecords',
      metadataPrefix: 'dif'
    }
  end
end
