require 'date'
require './lib/selectors/iso_namespaces'

# Methods for generating formatted strings that can be indexed by SOLR
module IsoToSolrFormat
  DATE = proc { |date | date_str date.text }
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
    separated_spatial_string box_node, ','
  end

  def self.spatial_index_str(box_node)
    separated_spatial_string box_node, ' '
  end

  def self.temporal_display_str(temporal_node)
    dr = date_range(temporal_node)
    "#{dr[:start]},#{dr[:end]}"
  end

  # We are indexiong date ranges a spatial cordinates ranging from 101 to 30000101.
  # This means we have to convert dates into the format YYYYMMDD which can be stored in our space
  # See http://wiki.apache.org/solr/SpatialForTimeDurations
  def self.temporal_index_str(temporal_node)
    dr = date_range(temporal_node)
    "#{format_date_for_index dr[:start]} #{format_date_for_index dr[:end]}"
  end

  private

  def self.separated_spatial_string(box_node, separator)
    box = bounding_box(box_node)
    [box[:west], box[:south], box[:east], box[:north]].join(separator)
  end

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
    {
      start: temporal_node.at_xpath('.//gml:beginPosition', ISO_NAMESPACES).text,
      end: temporal_node.at_xpath('.//gml:endPosition', ISO_NAMESPACES).text
    }
  end

  def self.format_date_for_index(date_str)
    DateTime.parse(date_str).strftime('%Y%m%d')
  end
end
