require 'json'
require 'rgeo/geo_json'
require 'rgeo/wkrep/wkt_parser'
require './lib/selectors/helpers/iso_to_solr_format'
require './lib/selectors/helpers/bounding_box_util'
require './lib/selectors/helpers/translate_spatial_coverage'
require './lib/selectors/helpers/translate_temporal_coverage'

# Translates Bcodmo json to solr json format
class BcodmoJsonToSolr
# rubocop:disable MethodLength
  def translate(json_doc, json_record, geometry)
    spatial_values = translate_geometry geometry
    temporal_coverage_values = TranslateTemporalCoverage.translate_coverages [{ 'start' => "#{ json_record['startDate'] }", 'end' => "#{ json_record['endDate'] }" }]
    {
      'title' => json_doc['dataset_name'],
      'authoritative_id' => json_record['id'] + json_doc['dataset_nid'],
      'dataset_version' => translate_dataset_version(json_doc['dataset_version']),
      'data_centers' => SolrFormat::DATA_CENTER_NAMES[:BCODMO][:long_name],
      'facet_data_center' => "#{SolrFormat::DATA_CENTER_NAMES[:BCODMO][:long_name]} | #{SolrFormat::DATA_CENTER_NAMES[:BCODMO][:short_name]}",
      'summary' => json_doc['dataset_description'].to_s.empty? ? json_doc['dataset_brief_description'] : json_doc['dataset_description'],
      'temporal_coverages' => temporal_coverage_values['temporal_coverages'],
      'temporal_duration' => temporal_coverage_values['temporal_duration'],
      'temporal' => temporal_coverage_values['temporal'],
      'facet_temporal_duration' => temporal_coverage_values['facet_temporal_duration'],
      'last_revision_date' => json_doc['dataset_deployment_version_date'].to_s.empty? ? nil : Time.parse(json_doc['dataset_deployment_version_date']).strftime('%Y-%m-%dT%H:%M:%SZ'),
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

  def translate_dataset_version(dataset_version)
    version_translation = dataset_version.to_s.gsub(/\D/, '')
    version_translation.empty? ? nil : version_translation
  end

  def translate_geometry(wkt_geom)
    wkt_geom['geometry'].sub! '<http://www.opengis.net/def/crs/OGC/1.3/CRS84> ', ''
    # Consider all linestring geometries to be multipoint for this provider
    wkt_geom['geometry'].sub! 'LINESTRING', 'MULTIPOINT'
    parser = RGeo::WKRep::WKTParser.new(nil, {})
    geometry = parser.parse(wkt_geom['geometry'])
    {
      spatial_display: TranslateSpatialCoverage.geojson_to_spatial_display_str([geometry]),
      spatial_index: TranslateSpatialCoverage.geojson_to_spatial_index_str([geometry]),
      spatial_area: TranslateSpatialCoverage.geojson_to_spatial_area([geometry]),
      global_facet: TranslateSpatialCoverage.geojson_to_global_facet([geometry]),
      spatial_scope_facet: TranslateSpatialCoverage.geojson_to_spatial_scope_facet([geometry])
    }
  end
end
