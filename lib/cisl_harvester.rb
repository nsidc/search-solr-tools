require_relative './selectors/helpers/iso_to_solr'
require_relative './harvester_base'
require_relative './selectors/helpers/query_builder'
require_relative './selectors/helpers/iso_namespaces'

# Harvests data from CISL and inserts it into Solr after it has been translated
class CislHarvester < HarvesterBase
  # Used in query string params, resumptionToken
  DATASET = '0bdd2d39-3493-4fa2-98f9-6766596bdc50'

  def initialize(env = 'development', die_on_failure = false)
    super env, die_on_failure
    @translator = IsoToSolr.new :cisl

    # This is updated when we harvest based on the response
    # from the server.
    @resumption_token = nil
  end

  def harvest_and_delete
    puts "Running harvest of CISL catalog from #{cisl_url}"
    super(method(:harvest_cisl_into_solr), "data_centers:\"#{SolrFormat::DATA_CENTER_NAMES[:CISL][:long_name]}\"")
  end

  # get translated entries from CISL and add them to Solr
  # this is the main entry point for the class
  def harvest_cisl_into_solr
    while @resumption_token.nil? || !@resumption_token.empty?
      entries = results_from_cisl

      begin
        insert_solr_docs(get_docs_with_translated_entries_from_cisl(entries))
      rescue => e
        puts "ERROR: #{e}"
        raise e if @die_on_failure
      end
    end
  end

  def cisl_url
    SolrEnvironments[@environment][:cisl_url]
  end

  def results_from_cisl
    list_records_oai_response = get_results(request_string, '//oai:ListRecords', '')

    @resumption_token = list_records_oai_response.xpath('.//oai:resumptionToken', IsoNamespaces.namespaces)
    @resumption_token = format_resumption_token(@resumption_token.first.text)

    list_records_oai_response.xpath('.//oai:record', IsoNamespaces.namespaces)
  end

  def get_docs_with_translated_entries_from_cisl(entries)
    docs = []
    entries.each { |r| docs.push(create_new_solr_add_doc_with_child(@translator.translate(r).root)) }
    docs
  end

  private

  def request_string
    params = {
      verb: 'ListRecords',
      metadataPrefix: 'dif',
      set: DATASET
    }.merge(
      @resumption_token.nil? ? {} : { resumptionToken: @resumption_token }
    )

    "#{ cisl_url }#{ QueryBuilder.build(params) }"
  end

  # The ruby response is lacking quotes, which the token requires in order to work...
  # Also, the response back seems to be inconsistent - sometimes it adds &quot; instead of '"',
  # which makes the token fail to work.
  # To get around this I'd prefer to make assumptions about the token and let it break if
  # they change the formatting.  For now, all fields other than offset should be able to be
  # assumed to remain constant.
  # If the input is empty, then we are done - return an empty string, which is checked for
  # in the harvest loop.
  def format_resumption_token(resumption_token)
    return '' if resumption_token.empty?

    resumption_token =~ /offset:(\d+)/
    offset = Regexp.last_match(1)

    '{"from":null,"until":null,"set":' <<
    "\"#{ DATASET }\"," <<
    '"metadataPrefix":"dif","offset":' <<
    "#{ offset }}"
  end
end
