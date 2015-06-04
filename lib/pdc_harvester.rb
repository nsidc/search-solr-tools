require_relative './oai_harvester'
require_relative './selectors/helpers/iso_namespaces'
require_relative './selectors/helpers/iso_to_solr'
require_relative './selectors/helpers/query_builder'

# Harvests data from Polar data catalogue and inserts it into
# Solr after it has been translated
class PdcHarvester < OaiHarvester
  @data_centers = SolrFormat::DATA_CENTER_NAMES[:PDC][:long_name]
  @translator = IsoToSolr.new :pdc

  def metadata_url
    SolrEnvironments[@environment][:pdc_url]
  end

  def results
    list_records_oai_response = get_results(request_string, '//oai:ListRecords', '')

    @resumption_token = list_records_oai_response.xpath('.//oai:resumptionToken', IsoNamespaces.namespaces).first.text

    list_records_oai_response.xpath('.//oai:record', IsoNamespaces.namespaces)
  end

  private

  def request_string
    # If a resumptionToken is supplied, don't include
    # metadataPrefix.
    params = {
      verb: 'ListRecords',
      metadataPrefix: @resumption_token.nil? ? 'iso' : nil,
      resumptionToken: @resumption_token
    }.delete_if { |k, v| v.nil? }

    "#{ metadata_url }#{ QueryBuilder.build(params) }"
  end
end
