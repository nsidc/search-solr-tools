require 'json'
require 'rest-client'
require 'rgeo/geo_json'
require 'rgeo/wkrep/wkt_parser'

require 'search_solr_tools/helpers'

module SearchSolrTools
  module Selectors
    # Translates Bcodmo json to solr json format
    class BcodmoJsonToSolr
      # rubocop:disable MethodLength
      # rubocop:disable AbcSize
      def translate(json_doc, json_record, geometry)
        originators = json_doc.key?('people') ? JSON.parse(RestClient.get((json_doc['people']))) : []
        spatial_values = translate_geometry geometry
        temporal_coverage_values = Helpers::TranslateTemporalCoverage.translate_coverages [{ 'start' => "#{json_record['startDate']}", 'end' => "#{json_record['endDate']}" }]
        {
          'title' => json_doc['dataset_name'],
          'authoritative_id' => json_record['id'] + json_doc['dataset_nid'],
          'dataset_version' => translate_dataset_version(json_doc['dataset_version']),
          'data_centers' => Helpers::SolrFormat::DATA_CENTER_NAMES[:BCODMO][:long_name],
          'facet_data_center' => "#{Helpers::SolrFormat::DATA_CENTER_NAMES[:BCODMO][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:BCODMO][:short_name]}",
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
          'spatial' => spatial_values[:spatial_index],
          'data_access_urls' => json_doc.key?('dataset_deployment_url') ? json_doc['dataset_deployment_url'] : [],
          'authors' => parse_people(originators)
        }
      end
      # rubocop:enable MethodLength

      def translate_dataset_version(dataset_version)
        version_translation = dataset_version.to_s.gsub(/\D/, '')
        version_translation.empty? ? nil : version_translation
      end

      def parse_people(people_json)
        people_json.map { |entry| entry['person_name'] } unless people_json.empty?
      end

      def translate_geometry(wkt_geom)
        wkt_geom['geometry'].sub! '<http://www.opengis.net/def/crs/OGC/1.3/CRS84> ', ''
        # Consider all linestring and polygon geometries to be multipoint for this provider
        wkt_geom['geometry'].sub! 'LINESTRING', 'MULTIPOINT'
        wkt_geom['geometry'].sub! 'POLYGON', 'MULTIPOINT'
        parser = RGeo::WKRep::WKTParser.new(nil, {})
        geometry = parser.parse(wkt_geom['geometry'])
        {
          spatial_display: Helpers::TranslateSpatialCoverage.geojson_to_spatial_display_str([geometry]),
          spatial_index: Helpers::TranslateSpatialCoverage.geojson_to_spatial_index_str([geometry]),
          spatial_area: Helpers::TranslateSpatialCoverage.geojson_to_spatial_area([geometry]),
          global_facet: Helpers::TranslateSpatialCoverage.geojson_to_global_facet([geometry]),
          spatial_scope_facet: Helpers::TranslateSpatialCoverage.geojson_to_spatial_scope_facet([geometry])
        }
      end
    end
  end
end