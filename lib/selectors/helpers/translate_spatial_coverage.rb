require 'rgeo/geo_json'
require './lib/selectors/helpers/bounding_box_util'
require './lib/selectors/helpers/iso_to_solr_format'

# Methods to translate geoJson spatial coverage object or list of objects to solr format values
module TranslateSpatialCoverage
  def self.geojson_to_spatial_display_str(spatial_coverage_geom)
    [*spatial_coverage_geom].map do |geom|
      bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geom)
      "#{bbox.min_y} #{bbox.min_x} #{bbox.max_y} #{bbox.max_x}"
    end
  end

  def self.geojson_to_spatial_index_str(spatial_coverage_geom)
    [*spatial_coverage_geom].map do |geo_json|
      if geo_json.geometry_type.to_s.downcase.eql?('point')
        "#{geo_json.x} #{geo_json.y}"
      else
        bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geo_json)
        "#{bbox.min_x} #{bbox.min_y} #{bbox.max_x} #{bbox.max_y}"
      end
    end
  end

  def self.geojson_to_spatial_area(spatial_coverage_geom)
    spatial_areas = [*spatial_coverage_geom].map do |geo_json|
      if %w(point multipoint).include?(geo_json.geometry_type.to_s.downcase)
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
    [*spatial_coverage_geom].each do |geo_json|
      bbox_hash = BoundingBoxUtil.bounding_box_hash_from_geo_json(geo_json)
      return 'Show Global Only' if BoundingBoxUtil.box_global?(bbox_hash)
    end
    nil
  end

  def self.geojson_to_spatial_scope_facet(spatial_coverage_geom)
    unless spatial_coverage_geom.nil?
      [*spatial_coverage_geom].map do |geo_json|
        bbox_hash = BoundingBoxUtil.bounding_box_hash_from_geo_json(geo_json)
        scope = SolrFormat.get_spatial_scope_facet_with_bounding_box(bbox_hash)
        scope unless scope.nil?
      end.uniq
    end
  end
end
