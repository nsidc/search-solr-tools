require_relative './selectors/helpers/iso_to_solr'
require_relative './harvester_base'
require_relative './selectors/helpers/query_builder'
require_relative './selectors/helpers/iso_namespaces'

# Harvests data from Polar data catalog and inserts it into
# Solr after it has been translated
class PdcHarvester < HarvesterBase
  def initialize(env = 'development', die_on_failure = false)
    super env, die_on_failure
    @translator = IsoToSolr.new :pdc

    # This is updated when we harvest based on the response
    # from the server.
    @resumption_token = nil
  end

  def harvest_and_delete
    puts "Running harvest of Polar data catalog from #{metadata_url}"
    super(method(:harvest_into_solr), "data_centers:\"#{SolrFormat::DATA_CENTER_NAMES[:PDC][:long_name]}\"")
  end

  # get translated entries from PDC and add them to Solr
  # this is the main entry point for the class
  def harvest_into_solr
    while @resumption_token.nil? || !@resumption_token.empty?
      begin
        insert_solr_docs(translated_docs(pull_records))
      rescue => e
        puts "ERROR: #{e}"
        raise e if @die_on_failure
      end
    end
  end

  def metadata_url
    SolrEnvironments[@environment][:pdc_url]
  end

  def pull_records
    list_records_oai_response = get_results(request_string, '//oai:ListRecords', '')

    @resumption_token = list_records_oai_response.xpath('.//oai:resumptionToken', IsoNamespaces.namespaces).first.text

    list_records_oai_response.xpath('.//oai:record', IsoNamespaces.namespaces)
  end

  def translated_docs(entries)
    entries.map { |e| create_new_solr_add_doc_with_child(@translator.translate(e).root) }
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
