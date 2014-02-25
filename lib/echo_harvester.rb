require 'nokogiri'
require './lib/csw_iso_query_builder'
require './lib/iso_to_solr'
require './lib/harvester_base'

# Harvests data from ECHO and inserts it into Solr after it has been translated
class EchoHarvester < HarvesterBase
  def initialize(env = 'development')
    super env
    @page_size = 100
    @translator = IsoToSolr.new :echo
  end

  # get translated entries from ECHO and add them to Solr
  # this is the main entry point for the class
  def harvest_echo_into_solr
    while (entries = get_results_from_echo) && (entries.length > 0)
      insert_solr_docs get_docs_with_translated_entries_from_echo(entries)
    end
  end

  def echo_url
    SolrEnvironments[@environment][:echo_url]
  end

  def get_results_from_echo
    get_results echo_url, '//gmi:MI_Metadata'
  end

  def get_docs_with_translated_entries_from_echo(entries)
    docs = []
    entries.each { |r| docs.push(create_new_solr_add_doc_with_child(@translator.translate(r).root)) }
    docs
  end
end
