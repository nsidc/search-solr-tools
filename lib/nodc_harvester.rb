require 'nokogiri'
require './lib/csw_iso_query_builder'
require './lib/iso_to_solr'
require './lib/harvester_base'

# Harvests data from NODC and inserts it into Solr after it has been translated
class NodcHarvester < HarvesterBase
  def initialize(env = 'development')
    super env
    @page_size = 100
    @translator = IsoToSolr.new :nodc
  end

  # get translated entries from NODC and add them to Solr
  # this is the main entry point for the class
  def harvest_nodc_into_solr
    start_index = 1
    while (entries = get_results_from_nodc(start_index)) && (entries.length > 0)
      insert_solr_docs get_docs_with_translated_entries_from_nodc(entries)
      start_index += @page_size
    end
  end

  def nodc_url
    SolrEnvironments[@environment][:nodc_url]
  end

  def get_results_from_nodc(start_index)
    get_results build_csw_request('results', @page_size, start_index), '//gmi:MI_Metadata'
  end

  def get_docs_with_translated_entries_from_nodc(entries)
    docs = []
    entries.each { |r| docs.push(create_new_solr_add_doc_with_child(@translator.translate(r).root)) }
    docs
  end

  def build_csw_request(resultType = 'results', maxRecords = '25', startPosition = '1')
    CswIsoQueryBuilder.get_query_string(nodc_url, {
      'resultType' => resultType,
      'maxRecords' => maxRecords,
      'startPosition' => startPosition,
      'constraint' => get_bbox_constraint
    })
  end

  def get_bbox_constraint
    bbox = {
      west: '-180',
      south: '45',
      east: '180',
      north: '90'
    }

    URI.encode '<Filter xmlns:ogc="http://www.opengis.net/ogc" ' +
      'xmlns:gml="http://www.opengis.net/gml" ' +
      'xmlns:apiso="http://www.opengis.net/cat/csw/apiso/1.0">' +
      '<ogc:BBOX><PropertyName>apiso:BoundingBox</PropertyName><gml:Envelope>' +
      '<gml:lowerCorner>' + bbox[:west] + ' ' + bbox[:south] + '</gml:lowerCorner>' +
      '<gml:upperCorner>' + bbox[:east] + ' ' + bbox[:north] + '</gml:upperCorner>' +
      '</gml:Envelope></ogc:BBOX></Filter>'
  end
end
