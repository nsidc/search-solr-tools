require './lib/selectors/helpers/iso_namespaces'

# Utility methods for dealing with bounding boxes.
module BoundingBoxUtil
  def self.bounding_box_hash_from_geo_json(geometry)
    if geometry.geometry_type.to_s.downcase.eql?('point')
      return { west: geometry.x.to_s, south: geometry.y.to_s, east: geometry.x.to_s, north: geometry.y.to_s }
    else
      bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geometry)
      return { west: bbox.min_x.to_s, south: bbox.min_y.to_s, east: bbox.max_x.to_s, north: bbox.max_y.to_s }
    end
  end

  def self.box_global?(box)
    box[:south].to_f < -85.0 && box[:north].to_f > 85.0
  end

  def self.box_local?(box)
    distance = box[:north].to_f - box[:south].to_f
    distance < 1
  end

  def self.box_invalid?(box)
    [:north, :south, :east, :west].any? { |d| box[d].nil? || box[d].empty? }
  end
end
