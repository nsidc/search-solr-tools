require 'gi_cat_driver'
require './lib/ade_csw_iso_query_builder'
require './lib/iso_to_solr'
require './lib/harvester_base'

# Harvests data from GI-Cat and inserts it into Solr after it has been translated
class ADEHarvester < HarvesterBase
  attr_accessor :page_size, :profile

  def initialize(env = 'development', profile_name = 'CISL')
    super env
    @page_size = 100
    profile_name == nil ? @profile = 'CISL' : @profile = profile_name # for some reason the default param value was not working
    @translator = IsoToSolr.new :cisl
    @gi_cat = GiCatDriver::GiCat.new(gi_cat_url, 'admin', 'abcd123$')
  end

  # get translated entries from GI-Cat and add them to Solr
  # this is the main entry point for the class
  def harvest_gi_cat_into_solr
    puts "Enabling profile: #{@profile}"
    @gi_cat.enable_profile @profile
    insert_solr_docs get_doc_with_translated_entries_from_gi_cat
  end

  # returns a Nokogiri XML document with structure
  # <add> <doc><doc>...<doc> </add>
  # this structure can be POSTed to Solr to update the db
  #
  # each entry from GI-Cat is translated to our Solr format, then
  # inserted into a <doc> element
  def get_doc_with_translated_entries_from_gi_cat
    doc = create_new_solr_add_doc
    start_index = 1
    while (entries = get_results_from_gi_cat(start_index)) && (entries.length > 0)
      entries.each { |entry| doc.root.add_child @translator.translate(entry).root }
      start_index += @page_size
    end
    doc
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
    csw_query_url + ADECswIsoQueryBuilder.get_query_string({
        'resultType' => resultType,
        'maxRecords' => maxRecords,
        'startPosition' => startPosition
    })
  end
end
