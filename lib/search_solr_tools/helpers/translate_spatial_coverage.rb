require 'rgeo/geo_json'

require_relative 'bounding_box_util'

module SearchSolrTools
  module Helpers
    # Methods to translate list of geoJson objects to solr format values
    module TranslateSpatialCoverage
      def self.geojson_to_spatial_display_str(spatial_coverage_geom)
        spatial_coverage_geom = convert_multipoint_to_point(spatial_coverage_geom)
        spatial_coverage_geom.map do |geom|
          bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geom)
          "#{bbox.min_y} #{bbox.min_x} #{bbox.max_y} #{bbox.max_x}"
        end
      end

      def self.convert_multipoint_to_point(spatial_coverage_geom)
        return_geom = []
        spatial_coverage_geom.each do |geom|
          if geom.geometry_type.to_s.downcase.eql?('multipoint')
            geom.each do |point|
              return_geom << point
            end
          else
            return_geom << geom
          end
        end
        return_geom
      end

      def self.geojson_to_spatial_index_str(spatial_coverage_geom)
        spatial_coverage_geom = convert_multipoint_to_point(spatial_coverage_geom)
        spatial_coverage_geom.map do |geo_json|
          if geo_json.geometry_type.to_s.downcase.eql?('point')
            "#{geo_json.x} #{geo_json.y}"
          else
            bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geo_json)
            "ENVELOPE(#{bbox.min_x}, #{bbox.max_x}, #{bbox.max_y}, #{bbox.min_y})"
          end
        end
      end

      def self.geojson_to_spatial_area(spatial_coverage_geom)
        spatial_areas = spatial_coverage_geom.map do |geo_json|
          if %w(point).include?(geo_json.geometry_type.to_s.downcase)
            0.0
          else
            bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geo_json)
            bbox.max_y - bbox.min_y
          end
        end
        return nil if spatial_areas.empty?
        spatial_areas.sort.last
      end

      def self.geojson_to_global_facet(spatial_coverage_geom)
        return nil if spatial_coverage_geom.nil?
        spatial_coverage_geom.each do |geo_json|
          bbox_hash = BoundingBoxUtil.bounding_box_hash_from_geo_json(geo_json)
          return 'Show Global Only' if BoundingBoxUtil.box_global?(bbox_hash)
        end
        nil
      end

      def self.geojson_to_spatial_scope_facet(spatial_coverage_geom)
        unless spatial_coverage_geom.nil?
          spatial_coverage_geom.map do |geo_json|
            bbox_hash = BoundingBoxUtil.bounding_box_hash_from_geo_json(geo_json)
            scope = SolrFormat.get_spatial_scope_facet_with_bounding_box(bbox_hash)
            scope unless scope.nil?
          end.uniq
        end
      end
    end
  end
end
