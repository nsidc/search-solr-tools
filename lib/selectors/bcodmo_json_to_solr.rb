require 'json'
require 'rgeo/geo_json'
require 'rgeo/wkrep/wkt_parser'
require './lib/selectors/helpers/iso_to_solr_format'
require './lib/selectors/helpers/bounding_box_util'
require './lib/selectors/helpers/translate_spatial_coverage'

# Translates Bcodmo json to solr json format
class BcodmoJsonToSolr
# geometry = @translator.translate_geometry get_json(record['geometryUrl'])
# rubocop:disable MethodLength
  def translate(json_doc, json_record, geometry)
    spatial_values = translate_geometry geometry
    temporal_coverage_values = translate_temporal_coverage_values([{ 'start' => "#{ json_record['startDate'] }", 'end' => "#{ json_record['endDate'] }" }])
    json_doc['dataset_description'].empty? ? description = json_doc['dataset_brief_description'] : description = json_doc['dataset_description']
    {
      'title' => json_doc['dataset_name'],
      'authoritative_id' => json_record['id'] + json_doc['dataset_nid'],
      'dataset_version' => json_doc['dataset_vesrsion'].to_s.empty? ? nil : json_doc['dataset_version'].gsub(/\D/, ''),
      'data_centers' => SolrFormat::DATA_CENTER_NAMES[:BCODMO][:long_name],
      'facet_data_center' => "#{SolrFormat::DATA_CENTER_NAMES[:BCODMO][:long_name]} | #{SolrFormat::DATA_CENTER_NAMES[:BCODMO][:short_name]}",
      'summary' => description,
      'temporal_coverages' => temporal_coverage_values['temporal_coverages'],
      'temporal_duration' => temporal_coverage_values['temporal_duration'],
      'temporal' => temporal_coverage_values['temporal'],
      'facet_temporal_duration' => temporal_coverage_values['facet_temporal_duration'],
      'last_revision_date' => translate_last_revision_date(json_doc['dataset_deployment_version_date']),
      'dataset_url' => json_doc['dataset_url'],
      'source' => 'ADE',
      'facet_spatial_coverage' => spatial_values[:global_facet],
      'facet_spatial_scope' => spatial_values[:spatial_scope_facet],
      'spatial_coverages' => spatial_values[:spatial_display],
      'spatial_area' => spatial_values[:spatial_area],
      'spatial' => spatial_values[:spatial_index]
    }
  end
# rubocop:enable MethodLength

  def translate_last_revision_date(datestring)
    datestring.to_s.empty? ? nil : Time.parse(datestring).strftime('%Y-%m-%d') + 'T00:00:00Z'
  end

  def translate_temporal_coverage_values(temporal_coverages_json)
    temporal_coverages = []
    temporal = []
    temporal_durations = []
    temporal_coverages_json.each do |coverage|
      start_time = Time.parse(coverage['start']) unless coverage['start'].to_s.empty?
      end_time = Time.parse(coverage['end']) unless coverage['end'].to_s.empty?
      temporal_durations << (SolrFormat.get_temporal_duration start_time, end_time)
      temporal_coverages << SolrFormat.temporal_display_str(start: (start_time.to_s.empty? ? nil : start_time.strftime('%Y-%m-%d')), end: (end_time.to_s.empty? ? nil : end_time.strftime('%Y-%m-%d')))
      temporal << SolrFormat.temporal_index_str(start: start_time.to_s, end: end_time.to_s)
    end unless temporal_coverages_json.nil?
    max_temporal_duration = SolrFormat.reduce_temporal_duration temporal_durations
    facet = SolrFormat.get_temporal_duration_facet max_temporal_duration
    { 'temporal_coverages' => temporal_coverages, 'temporal_duration' => max_temporal_duration, 'temporal' => temporal, 'facet_temporal_duration' => facet  }
  end

  def translate_geometry(geo_json)
    translation = {}
    geo_json['geometry'].sub! '<http://www.opengis.net/def/crs/OGC/1.3/CRS84> ', ''
    parser = RGeo::WKRep::WKTParser.new(nil, {})
    geometry = parser.parse(geo_json['geometry'])
    translation[:spatial_display] = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_display_str(geometry)
    translation[:spatial_index] = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_index_str(geometry)
    translation[:spatial_area] = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_area(geometry)
    translation[:global_facet] = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_global_facet(geometry)
    translation[:spatial_scope_facet] = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_scope_facet(geometry)
    translation
  end
end
