require 'date'
require File.join(File.dirname(__FILE__), 'iso_namespaces')
require File.join(File.dirname(__FILE__), 'solr_format')

# Methods for generating formatted strings from ISO xml nodes that can be indexed by SOLR
# rubocop:disable ClassLength
class IsoToSolrFormat
  KEYWORDS = proc { |keywords| build_keyword_list keywords }

  SPATIAL_DISPLAY = proc { |node| IsoToSolrFormat.spatial_display_str(node) }
  SPATIAL_INDEX = proc { |node| IsoToSolrFormat.spatial_index_str(node) }
  SPATIAL_AREA = proc { |node| IsoToSolrFormat.spatial_area_str(node) }
  MAX_SPATIAL_AREA = proc { |values| IsoToSolrFormat.get_max_spatial_area(values) }

  FACET_SPONSORED_PROGRAM = proc { |node| IsoToSolrFormat.sponsored_program_facet node }
  FACET_SPATIAL_COVERAGE = proc { |node| IsoToSolrFormat.get_spatial_facet(node) }
  FACET_SPATIAL_SCOPE = proc { |node| IsoToSolrFormat.get_spatial_scope_facet(node) }
  FACET_TEMPORAL_DURATION = proc { |node| IsoToSolrFormat.get_temporal_duration_facet(node) }

  TEMPORAL_DURATION = proc { |node| IsoToSolrFormat.get_temporal_duration(node) }
  TEMPORAL_INDEX_STRING = proc { |node| IsoToSolrFormat.temporal_index_str node }
  TEMPORAL_DISPLAY_STRING = proc { |node| IsoToSolrFormat.temporal_display_str node }
  TEMPORAL_DISPLAY_STRING_FORMATTED = proc { |node| IsoToSolrFormat.temporal_display_str(node, true) }

  TITLE_FORMAT = proc { |node| IsoToSolrFormat.title_format(node) }

  DATASET_URL = proc { |node| IsoToSolrFormat.dataset_url(node) }
  ICES_DATASET_URL = proc { |node| IsoToSolrFormat.ices_dataset_url(node) }
  EOL_AUTHOR_FORMAT = proc { |node| IsoToSolrFormat.eol_author_format(node) }

  def self.spatial_display_str(box_node)
    box = bounding_box(box_node)
    "#{box[:south]} #{box[:west]} #{box[:north]} #{box[:east]}"
  end

  def self.spatial_index_str(box_node)
    box = bounding_box(box_node)
    if box[:west] == box[:east] && box[:south] == box[:north]
      [box[:west], box[:south]]
    else
      [box[:west], box[:south], box[:east], box[:north]]
    end.join(' ')
  end

  def self.spatial_area_str(box_node)
    box = bounding_box(box_node)
    area = box[:north].to_f - box[:south].to_f
    area
  end

  def self.get_max_spatial_area(values)
    values.map(&:to_f).max
  end

  def self.get_spatial_facet(box_node)
    box = bounding_box(box_node)

    if BoundingBoxUtil.box_invalid?(box)
      facet = nil
    elsif BoundingBoxUtil.box_global?(box)
      facet = 'Global'
    else
      facet = 'Non Global'
    end
    facet
  end

  def self.get_spatial_scope_facet(box_node)
    box = bounding_box(box_node)
    SolrFormat.get_spatial_scope_facet_with_bounding_box(box)
  end

  def self.temporal_display_str(temporal_node, formatted = false)
    SolrFormat.temporal_display_str(date_range(temporal_node, formatted))
  end

  def self.get_temporal_duration(temporal_node)
    dr = date_range(temporal_node)
    dr[:end].to_s.empty? ? end_time = Time.now : end_time = Time.parse(dr[:end])
    dr[:start].to_s.empty? ? duration = nil : duration = SolrFormat.get_temporal_duration(Time.parse(dr[:start]), end_time)
    duration
  end

  def self.get_temporal_duration_facet(temporal_node)
    duration = get_temporal_duration(temporal_node)
    SolrFormat.get_temporal_duration_facet(duration)
  end

  def self.temporal_index_str(temporal_node)
    dr = date_range(temporal_node)
    SolrFormat.temporal_index_str(dr)
  end

  def self.sponsored_program_facet(node)
    long_name = node.xpath('.//gmd:organisationName', IsoNamespaces.namespaces(node)).text.strip
    short_name = node.xpath('.//gmd:organisationShortName', IsoNamespaces.namespaces(node)).text.strip

    [long_name, short_name].join(' | ')
  end

  def self.build_keyword_list(keywords)
    category = keywords.xpath('.//CategoryKeyword').text
    topic = keywords.xpath('.//TopicKeyword').text
    term = keywords.xpath('.//TermKeyword').text
    category << ' > ' << topic << ' > ' << term
  end

  def self.date_range(temporal_node, formatted = false)
    start_date = get_first_matching_child(
      temporal_node,
      ['.//gml:beginPosition', './/BeginningDateTime', './/gco:Date', './/dif:Start_Date']
    )
    start_date = '' unless SolrFormat.date?(start_date)
    start_date = SolrFormat.date_str(start_date) if formatted

    end_date = get_first_matching_child(
      temporal_node,
      ['.//gml:endPosition', './/EndingDateTime', './/gco:Date', './/dif:Stop_Date']
    )
    end_date = '' unless SolrFormat.date?(end_date)
    end_date = SolrFormat.date_str(end_date) if formatted

    {
      start: start_date,
      end: end_date
    }
  end

  def self.title_format(node)
    node.text.strip =~ /not available/i ? 'Dataset title not available' : node.text.strip
  end

  # Met.no sometimes has bad metadata, such as <gmd:URL>SU-1 (planned activity)</gmd:URL>
  def self.dataset_url(url_node)
    url_node.text.strip =~ %r{http[s]?://} ? url_node.text.strip : ''
  end

  def self.ices_dataset_url(auth_id)
    'http://geo.ices.dk/geonetwork/srv/en/main.home?uuid=' + auth_id
  end

  def self.eol_author_format(node)
    name = ''
    matches = node.xpath('./gmd:role/gmd:CI_RoleCode').attribute('codeListValue').to_s.include?('author')
    if matches
      name = node.xpath('./gmd:organisationName/gco:CharacterString', IsoNamespaces.namespaces(node)).text
      if name.include?(' AT ') && name.include?(' dot ')
        name = name[0..name.rindex(',') - 1]
      end
    end
    name
  end

  def self.get_first_matching_child(node, paths)
    matching_nodes = node.at_xpath(paths.join(' | '), IsoNamespaces.namespaces(node))
    matching_nodes.nil? ? '' : matching_nodes.text
  end

  def self.bounding_box(box_node)
    {
      west:  get_bound(box_node, :west),
      south: get_bound(box_node, :south),
      east:  get_bound(box_node, :east),
      north: get_bound(box_node, :north)
    }
  end

  def self.axis_label(direction)
    {
      north: 'Latitude',
      south: 'Latitude',
      east: 'Longitude',
      west: 'Longitude'
    }[direction]
  end

  def self.coordinate_boundary(lat_lon)
    {
      'Latitude' => 90,
      'Longitude' => 180
    }[lat_lon]
  end

  def self.node_values(box_node, direction, lat_lon)
    get_first_matching_child(
      box_node,
      [
        "./gmd:#{direction.to_s.downcase}Bounding#{lat_lon}/gco:Decimal",
        "./gmd:#{direction.to_s.downcase}Bound#{lat_lon}/gco:Decimal",
        "./#{direction.to_s.capitalize}BoundingCoordinate",
        "./dif:#{direction.to_s.capitalize}ernmost_#{lat_lon}"
      ]
    ).split(' ')
  end

  def self.get_bound(box_node, direction)
    lat_lon = axis_label(direction)

    vals = node_values(box_node, direction, lat_lon)
    val = vals.first

    boundary = coordinate_boundary(lat_lon)
    out_of_bounds = boundary < val.to_f.abs

    return '' if vals.empty? || out_of_bounds

    val = (-val.to_f) if %w(West South).include?(vals.last)

    val.to_f.to_s
  end
end
