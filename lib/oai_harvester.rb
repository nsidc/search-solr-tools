require 'json'

require_relative './harvester_base'
require_relative './selectors/helpers/iso_namespaces'
require_relative './selectors/helpers/query_builder'

class OaiHarvester < HarvesterBase
  # Used in query string params, resumptionToken

  def initialize(env = 'development', die_on_failure = false)
    super env, die_on_failure
    # This is updated when we harvest based on the response
    # from the server.
    @resumption_token = nil
  end

  def encode_data_provider_url(url)
    URI.encode(url)
  end

  def harvest_and_delete
    puts "Running #{self.class.name} at #{metadata_url}"
    super(method(:harvest), %(data_centers:"#{@data_centers}"))
  end

  def harvest
    while @resumption_token.nil? || !@resumption_token.empty?
      begin
        insert_solr_docs(translated_docs(results))
      rescue => e
        puts "ERROR: #{e}"
        raise e if @die_on_failure
      end
    end
  end

  def results
    fail NotImplementedError
  end

  def metadata_url
    fail NotImplementedError
  end

  def translated_docs(entries)
    entries.map { |e| create_new_solr_add_doc_with_child(@translator.translate(e).root) }
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

    ## TODO eval metadata_url being nil

    "#{ metadata_url }#{ QueryBuilder.build(params) }"
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

    {
      from: nil,
      until: nil,
      set: DATASET,
      metadataPrefix: 'dif',
      offset: offset
    }.to_json
  end
end
