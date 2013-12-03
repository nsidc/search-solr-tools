require 'debugger'
require 'date'
require './lib/selectors/iso_namespaces'

# Methods for generating formatted strings that can be indexed by SOLR
module IsoToSolrFormat
  DATE = proc { |date | date_str date.text }
  SPATIAL_DISPLAY = proc { |node| IsoToSolrFormat.spatial_display_str node }
  SPATIAL_INDEX = proc { |node| IsoToSolrFormat.spatial_index_str node }

  FACET_SPATIAL_COVERAGE = proc { |node| IsoToSolrFormat.get_spatial_facet node }
  FACET_TEMPORAL_DURATION = proc { |node| IsoToSolrFormat.get_temporal_duration_facet node }

  def self.date_str(date)
    d = if date.is_a? String
          DateTime.parse(date.strip)
        else
          date
        end
    "#{d.iso8601[0..-7]}Z"
  end

  def self.fix_dryads_url(id_node)
    # Dryad does not provide links but this is a handy way to get to the datasets
    data_link = 'http://datadryad.org/handle/' + id_node
    data_link.gsub! 'oai:datadryad.org:', ''
  end

  def self.spatial_display_str(box_node)
    box = bounding_box(box_node)
    "#{box[:south]} #{box[:west]} #{box[:north]} #{box[:east]}"
  end

  def self.spatial_index_str(box_node)
    box = bounding_box(box_node)
    (if box[:west] == box[:east] && box[:east] == box[:north]
       [box[:west], box[:south]]
     else
       [box[:west], box[:south], box[:east], box[:north]]
     end).join(' ')
  end

  def self.temporal_display_str(temporal_node, formatted = false)
    dr = date_range(temporal_node, formatted)
    "#{dr[:start]},#{dr[:end]}"
  end

  def self.get_spatial_facet(box_node)
    box = bounding_box(box_node)
    facet = 'Non global'
    facet = 'Global' if box[:south].to_f < -89.0 && box[:north].to_f > 89.0
    facet
  end

  def self.get_temporal_duration_facet(temporal_node)
    duration = total_duration(temporal_node)
    facet = temporal_duration_range(duration)
    facet
  end

  # We are indexiong date ranges a spatial cordinates.
  # This means we have to convert dates into the format YY.YYMMDD which can be stored in the standard lat/long space
  # For example: 2013-01-01T00:00:00Z to 2013-01-31T00:00:00Z will be converted to 20.130101, 20.130131.
  # See http://wiki.apache.org/solr/SpatialForTimeDurations
  def self.temporal_index_str(temporal_node)
    dr = date_range(temporal_node)
    "#{format_date_for_index dr[:start], MIN_DATE} #{format_date_for_index dr[:end], MAX_DATE}"
  end

  private

  MIN_DATE = '00010101'
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
      matching_nodes = node.xpath(path, IsoNamespaces.get_namespaces(node))
      return matching_nodes if matching_nodes.size > 0
    end
  end

  def self.date_range(temporal_node, formatted = false)
    start_date = temporal_node.xpath('.//gml:beginPosition', IsoNamespaces.get_namespaces(temporal_node)).first.text
    end_date = temporal_node.xpath('.//gml:endPosition', IsoNamespaces.get_namespaces(temporal_node)).first.text
    formatted ? start_date = date_str(start_date) : start_date
    formatted ? end_date = date_str(end_date) : end_date
    {
      start: start_date.empty? ? '' : start_date,
      end: end_date.empty? ? '' : end_date
    }
  end

  def self.total_duration(date_ranges)
    dr = date_range(date_ranges)

    unless dr[:start].empty?
      start_date = Time.new(dr[:start])
      end_date = dr[:end].empty? ? Time.now : Time.new(dr[:end])

      # Time - Time returns seconds as a Float; we want the year as an integer
      duration = ((end_date - start_date) / Float(60 * 60 * 24 * 365)).to_int
    end
    duration
  end

  def self.temporal_duration_range(temporal_duration)
    range = case temporal_duration
            when nil then ''
            when 0 then '< 1 years'
            when 1..4 then '1 - 4 years'
            when 5..9 then '5 - 9 years'
            else '10+ years'
            end
    range
  end

  def self.format_date_for_index(date_str, default)
    date_str = default if date_str.eql?('')
    DateTime.parse(date_str).strftime('%C.%y%m%d')
  end
end
