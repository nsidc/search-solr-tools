require_relative './selectors/helpers/iso_to_solr'
require_relative './oai_harvester'
require_relative './selectors/helpers/query_builder'
require_relative './selectors/helpers/iso_namespaces'

# Harvests data from CISL and inserts it into Solr after it has been translated
class CislHarvester < OaiHarvester
  # Used in query string params, resumptionToken
  DATASET = '0bdd2d39-3493-4fa2-98f9-6766596bdc50'
  @data_centers = SolrFormat::DATA_CENTER_NAMES[:CISL][:long_name]
  @translator = IsoToSolr.new :cisl

  def metadata_url
    SolrEnvironments[@environment][:cisl_url]
  end

  def results
    list_records_oai_response = get_results(request_string, '//oai:ListRecords', '')

    @resumption_token = list_records_oai_response.xpath('.//oai:resumptionToken', IsoNamespaces.namespaces)
    @resumption_token = format_resumption_token(@resumption_token.first.text)

    list_records_oai_response.xpath('.//oai:record', IsoNamespaces.namespaces)
  end
end
