require 'date'
require './lib/selectors/iso_namespaces'

# Methods for generating formatted strings that can be indexed by SOLR
module IsoToSolrFormat
  DATE = proc { |date | date_str date.text }
  SPATIAL_DISPLAY = proc { |node| IsoToSolrFormat.spatial_display_str(node) }
  SPATIAL_INDEX = proc { |node| IsoToSolrFormat.spatial_index_str(node) }
  TEMPORAL_DURATION = proc { |node| IsoToSolrFormat.get_temporal_duration(node) }

  FACET_SPATIAL_COVERAGE = proc { |node| IsoToSolrFormat.get_spatial_facet(node) }
  FACET_SPATIAL_SCOPE = proc { |node| IsoToSolrFormat.get_spatial_scope_facet(node) }
  FACET_TEMPORAL_DURATION = proc { |node| IsoToSolrFormat.get_temporal_duration_facet(node) }

  REDUCE_TEMPORAL_DURATION = proc { |values| IsoToSolrFormat.reduce_temporal_duration(values) }

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

    if is_box_invalid(box)
      facet = 'No Spatial Information'
    elsif is_box_global(box)
      facet = 'Global'
    else
      facet = 'Non Global'
    end
    facet
  end

  def self.get_spatial_scope_facet(box_node)
    box = bounding_box(box_node)

    if is_box_invalid(box)
      facet = 'No Spatial Information'
    elsif is_box_global(box)
      facet = 'Global'
    elsif is_box_regional(box)
      facet = 'Regional'
    else
      facet = 'Local'
    end
    facet
  end

  # returns the temporal duration in days; returns -1 if there is not a valid
  # start date
  def self.get_temporal_duration(temporal_node)
    dr = date_range(temporal_node)

    if dr[:start].empty?
      duration = nil
    else
      start_date = Date.parse(dr[:start])
      end_date = dr[:end].empty? ? Time.now.to_date : Date.parse(dr[:end])

      # datasets that cover just one day would have end_date - start_date = 0,
      # so we need to add 1 to make sure the duration is the actual number of
      # days; if the end date and start date are flipped in the metadata, a
      # negative duration doesn't make sense so use the absolute value
      duration = Integer(end_date - start_date).abs + 1
    end
    duration
  end

  def self.get_temporal_duration_facet(temporal_node)
    duration = get_temporal_duration(temporal_node)
    temporal_duration_range(duration)
  end

  def self.reduce_temporal_duration(values)
    values.reject { |v| v.nil? }.max
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
    west = get_first_matching_child(box_node, ['./gmd:westBoundingLongitude/gco:Decimal', './gmd:westBoundLongitude/gco:Decimal'])
    south = get_first_matching_child(box_node, ['./gmd:southBoundingLatitude/gco:Decimal', './gmd:southBoundLatitude/gco:Decimal'])
    east = get_first_matching_child(box_node, ['./gmd:eastBoundingLongitude/gco:Decimal', './gmd:eastBoundLongitude/gco:Decimal'])
    north = get_first_matching_child(box_node, ['./gmd:northBoundingLatitude/gco:Decimal', './gmd:northBoundLatitude/gco:Decimal'])

    {
      west: west,
      south: south,
      east: east,
      north: north
    }
  end

  def self.get_first_matching_child(node, paths)
    text = ''
    paths.each do |path|
      matching_nodes = node.at_xpath(path, IsoNamespaces.get_namespaces(node))
      return matching_nodes.text.split(' ').first.strip unless matching_nodes.nil?
    end
    text
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

  # takes a temporal_duration in days, returns a string representing the range
  # for faceting
  def self.temporal_duration_range(temporal_duration)
    years = temporal_duration / 365
    range = case years
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

  def self.is_box_invalid(box)
    box[:north].nil? || box[:north].empty? ||
      box[:east].nil? || box[:east].empty? ||
      box[:south].nil? || box[:south].empty? ||
      box[:west].nil? || box[:west].empty?
  end

  def self.is_box_global(box)
    box[:south].to_f < -89.0 && box[:north].to_f > 89.0
  end

  def self.is_box_regional(box)
    distance = box[:north].to_f - box[:south].to_f
    distance > 1 && distance < 85.0
  end
end
