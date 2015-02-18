require_relative './selectors/helpers/iso_to_solr'
require_relative './harvester_base'
require_relative './selectors/helpers/query_builder'

# Harvests data from CISL and inserts it into Solr after it has been translated
class CislHarvester < HarvesterBase
  def initialize(env = 'development', die_on_failure = false)
    super env, die_on_failure
    @translator = IsoToSolr.new :cisl
  end

  def harvest_and_delete
    puts "Running harvest of CISL catalog from #{cisl_url}"
    super(method(:harvest_cisl_into_solr), "data_centers:\"#{SolrFormat::DATA_CENTER_NAMES[:CISL][:long_name]}\"")
  end

  # get translated entries from CISL and add them to Solr
  # this is the main entry point for the class
  def harvest_cisl_into_solr
    while (entries = get_results_from_cisl) && (entries.length > 0)
      begin
        insert_solr_docs get_docs_with_translated_entries_from_cisl(entries)
      rescue => e
        puts "ERROR: #{e}"
        raise e if @die_on_failure
      end
    end
  end

  def cisl_url
    SolrEnvironments[@environment][:cisl_url]
  end

  def get_results_from_cisl
    get_results(request_string, '//oai:record', '')
  end

  def get_docs_with_translated_entries_from_cisl(entries)
    docs = []
    entries.each { |r| docs.push(create_new_solr_add_doc_with_child(@translator.translate(r).root)) }
    docs
  end

  def request_string
    params = {
      verb: 'ListRecords',
      metadataPrefix: 'dif',
      set: '0bdd2d39-3493-4fa2-98f9-6766596bdc50'
    }

    "#{ cisl_url }#{ QueryBuilder.build(params) }"
  end
end
