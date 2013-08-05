require 'date'
require './lib/selectors/iso_namespaces'

# Methods for generating formatted strings that can be indexed by SOLR
module IsoToSolrFormat
  DATE = proc { |date | date_str date.text }
  SPATIAL_DISPLAY = proc { |node| IsoToSolrFormat.spatial_display_str node }
  SPATIAL_INDEX = proc { |node| IsoToSolrFormat.spatial_index_str node }

  def self.date_str(date)
    d = if date.is_a? String
          DateTime.parse(date.strip)
        else
          date
        end
    "#{d.iso8601[0..-7]}Z"
  end

  def self.spatial_display_str(box_node)
    box = bounding_box(box_node)
    "#{box[:west]},#{box[:south]},#{box[:east]},#{box[:north]}"
  end

  def self.spatial_index_str(box_node)
    box = bounding_box(box_node)
    (if box[:west] == box[:east] && box[:east] == box[:north]
       [box[:west], box[:south]]
     else
       [box[:west], box[:south], box[:east], box[:north]]
     end).join(' ')
  end

  def self.temporal_display_str(temporal_node)
    dr = date_range(temporal_node)
    "#{dr[:start]},#{dr[:end]}"
  end

  # We are indexiong date ranges a spatial cordinates.
  # This means we have to convert dates into the format YY.YYMMDD which can be stored in the standard lat/long space
  # For example: 2013-01-01T00:00:00Z to 2013-01-31T00:00:00Z will be converted to 20.130101, 20.130131.
  # See http://wiki.apache.org/solr/SpatialForTimeDurations
  def self.temporal_index_str(temporal_node)
    dr = date_range(temporal_node)
    "#{format_date_for_index dr[:start]} #{format_date_for_index dr[:end]}"
  end

  private

  MIN_DATE = '0'
  MAX_DATE = '30000101'

  def self.bounding_box(box_node)
    {
      west: get_first_matching_child(box_node, ['./gmd:westBoundingLongitude/gco:Decimal', './gmd:westBoundLongitude/gco:Decimal']).text,
      south: get_first_matching_child(box_node, ['./gmd:southBoundingLatitude/gco:Decimal', './gmd:southBoundLatitude/gco:Decimal']).text,
      east: get_first_matching_child(box_node, ['./gmd:eastBoundingLongitude/gco:Decimal', './gmd:eastBoundLongitude/gco:Decimal']).text,
      north: get_first_matching_child(box_node, ['./gmd:northBoundingLatitude/gco:Decimal', './gmd:northBoundLatitude/gco:Decimal']).text
    }
  end

  def self.get_first_matching_child(node, paths)
    paths.each do |path|
      matching_nodes = node.xpath(path, ISO_NAMESPACES)
      return matching_nodes if matching_nodes.size > 0
    end
  end

  def self.date_range(temporal_node)
    start_date = temporal_node.xpath('.//gml:beginPosition', ISO_NAMESPACES).first.text
    end_date = temporal_node.xpath('.//gml:endPosition', ISO_NAMESPACES).first.text
    {
      start: start_date.empty? ? MIN_DATE : start_date,
      end: end_date.empty? ? MAX_DATE : end_date
    }
  end

  def self.format_date_for_index(date_str)
    return date_str if date_str.eql?(MIN_DATE)
    DateTime.parse(date_str).strftime('%C.%y%m%d')
  end
end
