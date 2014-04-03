require 'gi_cat_driver'
require './lib/csw_iso_query_builder'
require './lib/iso_to_solr'
require './lib/harvester_base'

# Harvests data from GI-Cat and inserts it into Solr after it has been translated
class ADEHarvester < HarvesterBase
  attr_accessor :page_size, :profile

  def initialize(env = 'development', profile_name = 'CISL')
    super env
    @page_size = 100
    @profile = profile_name || 'CISL' # for some reason the default param value was not working
    @translator = IsoToSolr.new profile_name.downcase.to_sym
    @gi_cat = GiCatDriver::GiCat.new(gi_cat_url, 'admin', 'abcd123$')
  end

  # get translated entries from GI-Cat and add them to Solr
  # this is the main entry point for the class
  def harvest_gi_cat_into_solr
    puts "Enabling GI-Cat profile: #{@profile}"
    @gi_cat.enable_profile @profile
    harvest_iso_documents
  end

  # returns an array of Nokogiri XML documents with structure
  # <add><doc></add>
  # this structure can be POSTed to Solr to update the db
  #
  # each entry from GI-Cat is translated to our Solr format, then
  # inserted into a <doc> element
  def get_docs_with_translated_entries_from_gi_cat(entries)
    docs = []
    entries.each { |entry| docs.push(create_new_solr_add_doc_with_child(@translator.translate(entry).root)) }
    docs
  end

  def harvest_iso_documents
    start_index = 1
    while (entries = get_results_from_gi_cat(start_index)) && (entries.length > 0)
      begin
        insert_solr_docs get_docs_with_translated_entries_from_gi_cat(entries)
      rescue Exception => e
        puts "ERROR: #{e}"
      end
      start_index += @page_size
    end
  end

  # returns a Nokogiri NodeSet containing @page_size search results from GI-Cat
  def get_results_from_gi_cat(start_index)
    get_results build_csw_request('results', @page_size, start_index), '//gmd:MD_Metadata'
  end

  def gi_cat_url
    SolrEnvironments[@environment][:gi_cat_url]
  end

  def csw_query_url
    SolrEnvironments[@environment][:gi_cat_csw_url]
  end

  def build_csw_request(resultType = 'results', maxRecords = '25', startPosition = '1')
    CswIsoQueryBuilder.get_query_string(csw_query_url,
                                        'namespace' => 'xmlns(gmd=http://www.isotc211.org/2005/gmd)',
                                        'resultType' => resultType,
                                        'maxRecords' => maxRecords,
                                        'startPosition' => startPosition
    )
  end
end
