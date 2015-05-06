require File.join(File.dirname(__FILE__), 'iso_to_solr_format')
require File.join(File.dirname(__FILE__), 'iso_namespaces')
require File.join(File.dirname(__FILE__), 'solr_format')

# Special formatter for dealing with temporal metadata issues in the TDAR feed
class TdarFormat < IsoToSolrFormat
  SPATIAL_DISPLAY = proc { |node| TdarFormat.spatial_display_str(node) }
  SPATIAL_INDEX = proc { |node| TdarFormat.spatial_index_str(node) }
  FACET_SPATIAL_SCOPE = proc { |node| TdarFormat.get_spatial_scope_facet(node) }

  TEMPORAL_INDEX_STRING = proc { |node| TdarFormat.temporal_index_str(node) }
  TEMPORAL_DISPLAY_STRING = proc { |node| TdarFormat.temporal_display_str(node) }
  TEMPORAL_DISPLAY_STRING_FORMATTED = proc { |node| TdarFormat.temporal_display_str(node, true) }
  TEMPORAL_DURATION = proc { |node| TdarFormat.get_temporal_duration(node) }
  FACET_TEMPORAL_DURATION = proc { |node| TdarFormat.get_temporal_duration_facet(node) }

  def self.get_spatial_scope_facet(node)
    box = bounding_box(node)
    SolrFormat.get_spatial_scope_facet_with_bounding_box(box)
  end

  private

  def self.date_range(temporal_node, formatted = false)
    xpath = '.'
    namespaces = IsoNamespaces.namespaces(temporal_node)

    temporal_node_count = temporal_node.xpath(xpath, namespaces).size
    date_str = temporal_node.at_xpath(xpath, namespaces).text

    super if temporal_node_count != 1

    case date_str
    when /^[0-9]{4}$/
      year_to_range(date_str)
    when /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$/
      single_date_to_range(date_str)
    else
      super
    end
  end

  def self.single_date_to_range(date)
    {
      start: date,
      end: date
    }
  end

  def self.year_to_range(year)
    {
      start: "#{year}-01-01",
      end: "#{year}-12-31"
    }
  end

  # Bounding box is defined by two coordinates to create a point.
  # Create a bounding box from this point.
  def self.bounding_box(node)
    point = node.text.split(' ')
    {
      west: point[1],
      south: point[0],
      east: point[3],
      north: point[2]
    }
  end
end
