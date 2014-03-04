require 'nokogiri'
require './lib/csw_iso_query_builder'
require './lib/iso_to_solr'
require './lib/harvester_base'

# Harvests data from ICES and inserts it into Solr after it has been translated
class IcesHarvester < HarvesterBase
  def initialize(env = 'development')
    super env
    @page_size = 100
    @translator = IsoToSolr.new :ices
  end

  # get translated entries from ICES and add them to Solr
  # this is the main entry point for the class
  def harvest_ices_into_solr
    start_index = 1
    while (entries = get_results_from_ices(start_index)) && (entries.length > 0)
      insert_solr_docs get_docs_with_translated_entries_from_ices(entries)
      start_index += @page_size
    end
  end

  def ices_url
    SolrEnvironments[@environment][:ices_url]
  end

  def get_results_from_ices(start_index)
    get_results build_csw_request('results', @page_size, start_index), '//gmd:MD_Metadata'
  end

  def get_docs_with_translated_entries_from_ices(entries)
    docs = []
    entries.each { |r| docs.push(create_new_solr_add_doc_with_child(@translator.translate(r).root)) }
    docs
  end

  def build_csw_request(resultType = 'results', maxRecords = '25', startPosition = '1')
    CswIsoQueryBuilder.get_query_string(ices_url, {
      'resultType' => resultType,
      'maxRecords' => maxRecords,
      'startPosition' => startPosition,
      'constraintLanguage' => 'CQL_TEXT'
    })
  end

end
