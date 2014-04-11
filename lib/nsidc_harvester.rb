require 'nokogiri'
require './lib/selectors/helpers/iso_to_solr'
require './lib/harvester_base'

# Harvests data from NSIDC OAI and inserts it into Solr after it has been translated
class NsidcHarvester < HarvesterBase
  def initialize(env = 'development')
    super env
    @translator = IsoToSolr.new :nsidc
  end

  # get translated entries from NSIDC OAI and add them to Solr
  # this is the main entry point for the class
  def harvest_nsidc_oai_into_solr
    insert_solr_docs docs_with_translated_entries_from_nsidc
  end

  def results_from_nsidc
    get_results SolrEnvironments[@environment][:oai_url], '//gmi:MI_Metadata'
  end

  def docs_with_translated_entries_from_nsidc
    docs = []
    results_from_nsidc.each { |r| docs.push(create_new_solr_add_doc_with_child(@translator.translate(r).root)) }
    docs
  end
end
