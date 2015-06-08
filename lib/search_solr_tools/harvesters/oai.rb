require 'json'

require_relative './base'
require_relative '../helpers/iso_namespaces'
require_relative '../helpers/query_builder'

# Base class for harvesting Oai feeds into SOLR
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

  def request_params
    fail NotImplementedError
  end

  def request_string
    "#{metadata_url}#{QueryBuilder.build(request_params)}"
  end
end
