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


  def self.spatial_display_str(node)
    point = node.text.split(" ")
    west = point[0]
    south = point[1]
    east = point[0]
    north = point[1]

    "#{south} #{west} #{north} #{east}"
  end

  def self.spatial_index_str(node)
    point = node.text.split(" ")
    west = point[0]
    south = point[1]
    east = point[0]
    north = point[1]

    "#{west} #{south} #{east} #{north}"
  end

  def self.get_spatial_scope_facet(node)
    point = node.text.split(" ")
    box = {
      west: point[0],
      south: point[1],
      east: point[0],
      north: point[1]
    }

    SolrFormat.get_spatial_scope_facet_with_bounding_box(box)
  end

  def self.temporal_display_str(temporal_node, formatted = false)
    SolrFormat.temporal_display_str(date_range(temporal_node, formatted))
  end

  private

  # for TDAR, a single date entry (i.e., missing either start or end date, and
  # the value that is present is not clearly labeled) means the whole year if
  # just a year is given, or just a single day if just a single day is given
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
end
