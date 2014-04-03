require 'nokogiri'
require './lib/csw_iso_query_builder'
require './lib/iso_to_solr'
require './lib/harvester_base'

# Harvests data from ECHO and inserts it into Solr after it has been translated
class EchoHarvester < HarvesterBase
  def initialize(env = 'development')
    super env
    @page_size = 1000
    @translator = IsoToSolr.new :echo
  end

  # get translated entries from ECHO and add them to Solr
  # this is the main entry point for the class
  def harvest_echo_into_solr
    page_num = 1
    while (entries = get_results_from_echo(page_num)) && (entries.length > 0)
      begin
        insert_solr_docs get_docs_with_translated_entries_from_echo(entries)
      rescue => e
        puts "ERROR: #{e}\n\n"
      end
      page_num += 1
    end
  end

  def echo_url
    SolrEnvironments[@environment][:echo_url]
  end

  def get_results_from_echo(page_num)
    get_results build_request(@page_size, page_num), './/results/result', 'application/echo10+xml'
  end

  def get_docs_with_translated_entries_from_echo(entries)
    docs = []
    entries.each { |r| docs.push(create_new_solr_add_doc_with_child(@translator.translate(r).root)) }
    docs
  end

  def build_request(max_records = '25', page_num = '1')
    echo_url + '?page_size=' + max_records.to_s + '&page_num=' + page_num.to_s
  end
end
