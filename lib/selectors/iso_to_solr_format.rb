require 'date'
require './lib/selectors/helpers/iso_namespaces'
require './lib/selectors/helpers/nsidc_parameter_mapping'
require './lib/selectors/helpers/nsidc_format_mapping'
require './lib/selectors/solr_string_format'

# Methods for generating formatted strings that can be indexed by SOLR
module IsoToSolrFormat
  KEYWORDS = proc { |keywords| build_keyword_list keywords }

  SPATIAL_DISPLAY = proc { |node| IsoToSolrFormat.spatial_display_str(node) }
  SPATIAL_INDEX = proc { |node| IsoToSolrFormat.spatial_index_str(node) }
  SPATIAL_AREA = proc { |node| IsoToSolrFormat.spatial_area_str(node) }
  MAX_SPATIAL_AREA = proc { |values| IsoToSolrFormat.get_max_spatial_area(values) }
  TEMPORAL_DURATION_FROM_XML = proc { |node| IsoToSolrFormat.get_temporal_duration_from_xml_node(node) }

  FACET_SPONSORED_PROGRAM = proc { |node| IsoToSolrFormat.sponsored_program_facet node }
  FACET_SPATIAL_COVERAGE = proc { |node| IsoToSolrFormat.get_spatial_facet_from_xml_node(node) }
  FACET_SPATIAL_SCOPE = proc { |node| IsoToSolrFormat.get_spatial_scope_facet(node) }
  FACET_TEMPORAL_DURATION_FROM_XML = proc { |node| IsoToSolrFormat.get_temporal_duration_facet_from_xml_node(node) }

  TEMPORAL_INDEX_STRING = proc { |node| IsoToSolrFormat.temporal_index_str_from_xml node }
  TEMPORAL_DISPLAY_STRING = proc { |node| IsoToSolrFormat.temporal_display_str_from_xml node }
  TEMPORAL_DISPLAY_STRING_FORMATTED = proc { |node| IsoToSolrFormat.temporal_display_str_from_xml(node, true) }

  def self.spatial_display_str(box_node)
    box = bounding_box(box_node)
    "#{box[:south]} #{box[:west]} #{box[:north]} #{box[:east]}"
  end

  def self.spatial_index_str(box_node)
    box = bounding_box(box_node)
    (if box[:west] == box[:east] && box[:south] == box[:north]
       [box[:west], box[:south]]
     else
       [box[:west], box[:south], box[:east], box[:north]]
     end).join(' ')
  end

  def self.spatial_area_str(box_node)
    box = bounding_box(box_node)
    area = box[:north].to_f - box[:south].to_f
    area
  end

  def self.get_max_spatial_area(values)
    values.map { |v| v.to_f }.max
  end

  def self.get_spatial_facet_from_xml_node(box_node)
    box = bounding_box(box_node)
    SolrStringFormat.get_spatial_facet(box)
  end

  def self.get_spatial_scope_facet(box_node)
    box = bounding_box(box_node)
    SolrStringFormat.get_spatial_scope_facet_with_bounding_box(box)
  end

  def self.temporal_display_str_from_xml(temporal_node, formatted = false )
    SolrStringFormat.temporal_display_str(date_range(temporal_node, formatted))
  end

  def self.get_temporal_duration_from_xml_node(temporal_node)
    dr = date_range(temporal_node)
    dr[:end].to_s.empty? ? end_time = Time.now : end_time = Time.parse(dr[:end])
    dr[:start].to_s.empty? ? duration = nil : duration = SolrStringFormat::TEMPORAL_DURATION.call(Time.parse(dr[:start]), end_time)
    duration
  end

  def self.get_temporal_duration_facet_from_xml_node(temporal_node)
    duration = get_temporal_duration_from_xml_node(temporal_node)
    SolrStringFormat.get_temporal_duration_facet(duration)
  end

  def self.temporal_index_str_from_xml(temporal_node)
    dr = date_range(temporal_node)
    SolrStringFormat.temporal_index_str(dr)
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

  private

  def self.date?(date)
    valid_date = if date.is_a? String
                   d = DateTime.parse(date.strip) rescue false
                   DateTime.valid_date?(d.year, d.mon, d.day) unless d.eql?(false)
                 end
    valid_date
  end

  def self.format_date_for_index(date_str, default)
    date_str = default unless date? date_str
    DateTime.parse(date_str).strftime('%C.%y%m%d')
  end

  def self.date_range(temporal_node, formatted = false)
    start_date = get_first_matching_child(temporal_node, ['.//gml:beginPosition', './/BeginningDateTime'])
    start_date = date?(start_date) ? start_date : ''

    end_date = get_first_matching_child(temporal_node, ['.//gml:endPosition', './/EndingDateTime'])
    end_date = date?(end_date) ? end_date : ''

    formatted ? start_date = SolrStringFormat::STRING_DATE.call(start_date) : start_date   ## Fix this
    formatted ? end_date = SolrStringFormat::STRING_DATE.call(end_date) : end_date

    {
        start: start_date,
        end: end_date
    }
  end

  def self.get_first_matching_child(node, paths)
    matching_nodes = node.at_xpath(paths.join(' | '), IsoNamespaces.namespaces(node))
    matching_nodes.nil? ? '' : matching_nodes.text
  end

  def self.bounding_box(box_node)
    west = get_first_matching_child(box_node, ['./gmd:westBoundingLongitude/gco:Decimal', './gmd:westBoundLongitude/gco:Decimal', './WestBoundingCoordinate'])
    west = west.split(' ').first.strip unless west.empty?
    south = get_first_matching_child(box_node, ['./gmd:southBoundingLatitude/gco:Decimal', './gmd:southBoundLatitude/gco:Decimal', './SouthBoundingCoordinate'])
    south = south.split(' ').first.strip unless south.empty?
    east = get_first_matching_child(box_node, ['./gmd:eastBoundingLongitude/gco:Decimal', './gmd:eastBoundLongitude/gco:Decimal', './EastBoundingCoordinate'])
    east = east.split(' ').first.strip unless east.empty?
    north = get_first_matching_child(box_node, ['./gmd:northBoundingLatitude/gco:Decimal', './gmd:northBoundLatitude/gco:Decimal', './NorthBoundingCoordinate'])
    north = north.split(' ').first.strip unless north.empty?

    {
        west: west,
        south: south,
        east: east,
        north: north
    }
  end



end
