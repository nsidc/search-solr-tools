require 'json'
require 'rest-client'
require 'rgeo/geo_json'

require 'search_solr_tools'

module SearchSolrTools
  module Translators
    # Translates GTN-P json to solr json format
    class GtnpJsonToSolr
      # rubocop:disable AbcSize
      def translate(json_doc, json_record)
        json_geo = json_doc['geo'].nil? ? json_doc['coordinates'] : json_doc['geo']['coordinates']
        concatenated_name = "#{json_record['title']} - #{json_doc['name']}"
        spatial_values = translate_geometry json_geo
        {
          'title' => concatenated_name,
          'authoritative_id' => concatenated_name,
          'data_centers' => Helpers::SolrFormat::DATA_CENTER_NAMES[:GTNP][:long_name],
          'facet_data_center' => "#{Helpers::SolrFormat::DATA_CENTER_NAMES[:GTNP][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:GTNP][:short_name]}",
          'summary' => json_record['abstract'].to_s,
          'dataset_url' => json_doc['link'],
          'source' => 'ADE',
          'facet_spatial_scope' => spatial_values[:spatial_scope_facet],
          'spatial_coverages' => spatial_values[:spatial_display],
          'spatial_area' => spatial_values[:spatial_area],
          'spatial' => spatial_values[:spatial_index],
          'temporal_coverages' => Helpers::SolrFormat::NOT_SPECIFIED,
          'facet_temporal_duration' => Helpers::SolrFormat::NOT_SPECIFIED,
          'authors' => parse_people(json_doc)
        }
      end

      def parse_people(json_doc)
        people_found = []
        return people_found unless json_doc.key?('citation') && json_doc['citation'].key?('contacts')
        citation = json_doc['citation']
        citation['contacts'].each do |person|
          people_found << "#{person['givenName']} #{person['familyName']}"
        end
        people_found
      end

      def translate_geometry(json_geom)
        geo_string = "{\"type\":\"Point\",\"coordinates\":[#{json_geom['longitude']},#{json_geom['latitude']}]}"
        geometry = RGeo::GeoJSON.decode(geo_string, json_parser: :json)
        {
          spatial_display: Helpers::TranslateSpatialCoverage.geojson_to_spatial_display_str([geometry]),
          spatial_index: Helpers::TranslateSpatialCoverage.geojson_to_spatial_index_str([geometry]),
          spatial_area: Helpers::TranslateSpatialCoverage.geojson_to_spatial_area([geometry]),
          spatial_scope_facet: Helpers::TranslateSpatialCoverage.geojson_to_spatial_scope_facet([geometry])
        }
      end
    end
  end
end
