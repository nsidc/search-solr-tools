# rubocop:disable ClassLength
require './lib/selectors/iso_to_solr_format'
require 'rgeo/geo_json'
require 'iso8601'

# Translates NSIDC JSON format to Solr JSON add format
class NsidcJsonToSolr
  DATA_CENTER_LONG_NAME = 'National Snow and Ice Data Center'
  DATA_CENTER_SHORT_NAME = 'NSIDC'
  NOT_SPECIFIED_FACET_VALUE = 'Not specified'

  TEMPORAL_RESOLUTION_FACET_VALUES = %w(Subhourly Hourly Subdaily Daily Weekly Submonthly Monthly Subyearly Yearly Multiyearly)
  SUBHOURLY_INDEX = 0
  HOURLY_INDEX = 1
  SUBDAILY_INDEX = 2
  DAILY_INDEX = 3
  WEEKLY_INDEX = 4
  SUBMONTHLY_INDEX = 5
  MONTHLY_INDEX = 6
  SUBYEARLY_INDEX = 7
  YEARLY_INDEX = 8
  MULTIYEARLY_INDEX = 9

# rubocop:disable MethodLength
  def translate(json_doc)
    copy_keys = %w(title summary keywords brokered)
    temporal_values = generate_temporal_values(json_doc['temporalCoverages'])
    solr_add_hash = json_doc.select { |k, v| copy_keys.include?(k) }
    solr_add_hash.merge!(
      'authoritative_id' => json_doc['authoritativeId'],
      'dataset_version' => json_doc['majorVersion']['version'],
      'data_centers' => DATA_CENTER_LONG_NAME,
      'facet_data_center' => "#{DATA_CENTER_LONG_NAME} | #{DATA_CENTER_SHORT_NAME}",
      'authors' => translate_personnel_to_authors(json_doc['personnel']),
      'topics' => translate_iso_topic_categories(json_doc['isoTopicCategories']),
      'parameters' => translate_parameters(json_doc['parameters']),
      'full_parameters' => translate_parameters_to_string(json_doc['parameters']),
      'facet_parameter' => translate_parameters_to_facet_parameters(json_doc['parameters']),
      'platforms' => translate_json_string(json_doc['platforms']),
      'sensors' => translate_json_string(json_doc['instruments']),
      'published_date' => (SolrStringFormat.date_str json_doc['releaseDate']),
      'spatial_coverages' => translate_spatial_coverage_geom_to_spatial_display_str(json_doc['spatial_coverages']),
      'spatial' => translate_spatial_coverage_geom_to_spatial_index_str(json_doc['spatial_coverages']),
      'spatial_area' => translate_spatial_coverage_geom_to_spatial_area(json_doc['spatial_coverages']),
      'facet_spatial_coverage' => translate_spatial_coverage_geom_to_global_facet(json_doc['spatial_coverages']),
      'facet_spatial_scope' => translate_spatial_coverage_geom_to_spatial_scope_facet(json_doc['spatial_coverages']),
      'temporal_coverages' => temporal_values['temporal_coverages'],
      'temporal_duration' => temporal_values['temporal_duration'],
      'temporal' => temporal_values['temporal'],
      'facet_temporal_duration' => temporal_values['facet_temporal_duration'],
      'last_revision_date' => (SolrStringFormat.date_str json_doc['lastRevisionDate']),
      'dataset_url' => json_doc['datasetUrl'],
      'distribution_formats' => json_doc['distributionFormats'],
      'facet_format' => ((json_doc['distributionFormats'].empty?) ? ['Not specified'] : json_doc['distributionFormats']),
      'source' => %w(NSIDC ADE),
      'popularity' => json_doc['popularity'],
      'facet_sponsored_program' => translate_internal_data_centers_to_facet_sponsored_program(json_doc['internalDataCenters']),
      'facet_temporal_resolution' => generate_temporal_resolution_facet_values(json_doc['parameters'])
    )
  end
# rubocop:enable MethodLength

  def generate_temporal_values(temporal_coverages_json)
    temporal_coverages = []
    temporal = []
    temporal_durations = []
    temporal_coverages_json.each do |coverage|
      start_time = Time.parse(coverage['start']) unless coverage['start'].to_s.empty?
      end_time = Time.parse(coverage['end']) unless coverage['end'].to_s.empty?
      temporal_durations << (SolrStringFormat.get_temporal_duration start_time, end_time)
      temporal_coverages << SolrStringFormat.temporal_display_str(start: (start_time.to_s.empty? ? nil : start_time.strftime('%Y-%m-%d')), end: (end_time.to_s.empty? ? nil : end_time.strftime('%Y-%m-%d')))
      temporal << SolrStringFormat.temporal_index_str(start: start_time.to_s, end: end_time.to_s)
    end unless temporal_coverages_json.nil?
    max_temporal_duration = SolrStringFormat.reduce_temporal_duration temporal_durations
    facet = SolrStringFormat.get_temporal_duration_facet max_temporal_duration
    { 'temporal_coverages' => temporal_coverages, 'temporal_duration' => max_temporal_duration, 'temporal' => temporal, 'facet_temporal_duration' => facet  }
  end

  # rubocop:disable MethodLength, CyclomaticComplexity
  def bin_temporal_resolution_value(temporal_resolution)
    return NOT_SPECIFIED_FACET_VALUE if temporal_resolution.nil? || temporal_resolution.empty?

    if temporal_resolution['type'] == 'single'
      return 'Not specified' if temporal_resolution['resolution'].nil? || temporal_resolution['resolution'].empty?
      i = find_index_for_single_temporal_resolution_value ISO8601::Duration.new(temporal_resolution['resolution'])
      return TEMPORAL_RESOLUTION_FACET_VALUES[i]
    elsif temporal_resolution['type'] == 'range'
      return 'Not specified' if temporal_resolution['min_resolution'].nil? || temporal_resolution['min_resolution'].empty?
      i = find_index_for_single_temporal_resolution_value ISO8601::Duration.new(temporal_resolution['min_resolution'])
      j = find_index_for_single_temporal_resolution_value ISO8601::Duration.new(temporal_resolution['max_resolution'])
      return TEMPORAL_RESOLUTION_FACET_VALUES[i..j]
    else
      return NOT_SPECIFIED_FACET_VALUE
    end
  end

  def find_index_for_single_temporal_resolution_value(iso8601_duration)
    dur_sec = iso8601_duration.to_seconds
    if dur_sec < 3600
      return SUBHOURLY_INDEX
    elsif dur_sec == 3600
      return HOURLY_INDEX
    elsif dur_sec < 86_400 # && dur.to_seconds > 3600
      return SUBDAILY_INDEX
    elsif dur_sec <= 172_800 # && dur_sec >= 86_400 - This is 1 to 2 days
      return DAILY_INDEX
    elsif dur_sec <= 691_200 # && dur_sec >= 172_800 - This is 3 to 8 days
      return WEEKLY_INDEX
    elsif dur_sec <= 1_728_000 # && dur_sec >= 691200 - This is 8 to 20 days
      return SUBMONTHLY_INDEX
    elsif iso8601_duration == ISO8601::Duration.new('P1M') || dur_sec <= 2_678_400 # && dur_sec >= 2_678_400 - 21 to 31 days
      return MONTHLY_INDEX
    elsif (iso8601_duration.months.to_i > 1 && iso8601_duration.months.to_i < 12 && iso8601_duration.years.to_i == 0) ||
        (dur_sec < 31_536_000)
      return SUBYEARLY_INDEX
    elsif iso8601_duration == ISO8601::Duration.new('P1Y')
      return YEARLY_INDEX
    else # elsif dur_sec > 31536000
      return MULTIYEARLY_INDEX
    end
  end
  # rubocop:enable MethodLength, CyclomaticComplexity

  def translate_iso_topic_categories(iso_topic_categories_json)
    iso_topic_categories_json.map { |t| t['name'] } unless iso_topic_categories_json.nil?
  end

  def translate_internal_data_centers_to_facet_sponsored_program(internal_datacenters_json)
    internal_data_centers = []
    internal_datacenters_json.each do |datacenter|
      internal_data_centers << datacenter['longName'] + ' | ' + datacenter['shortName']
    end
    internal_data_centers
  end

  def translate_personnel_to_authors(personnel_json)
    authors = []
    personnel_json.each do |person|
      unless person['firstName'].eql?('NSIDC') && person['lastName'].eql?('User Services')
        author_string = person['firstName']
        author_string = author_string + ' ' + person['middleName'] unless person['middleName'].to_s.empty?
        author_string = author_string + ' ' + person['lastName'] unless person['lastName'].to_s.empty?
        unless author_string.to_s.empty?
          author_string.strip!
          authors << author_string
        end
      end
    end
    authors
  end

  def translate_spatial_coverage_geom_to_spatial_display_str(spatial_coverage_geom)
    spatial_coverage_strs = []
    spatial_coverage_geom.each do |geom|
      geo_json = RGeo::GeoJSON.decode(geom['geom4326'])
      bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geo_json)
      spatial_coverage_strs << "#{bbox.min_y} #{bbox.min_x} #{bbox.max_y} #{bbox.max_x}"
    end
    spatial_coverage_strs
  end

  def translate_spatial_coverage_geom_to_spatial_index_str(spatial_coverage_geom)
    spatial_index_strs = []
    spatial_coverage_geom.each do |geom|
      geo_json = RGeo::GeoJSON.decode(geom['geom4326'])
      if geo_json.geometry_type.to_s.downcase.eql?('point')
        spatial_index_strs << "#{geo_json.x} #{geo_json.y}"
      else
        bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geo_json)
        spatial_index_strs << "#{bbox.min_x} #{bbox.min_y} #{bbox.max_x} #{bbox.max_y}"
      end
    end
    spatial_index_strs
  end

  def translate_spatial_coverage_geom_to_spatial_area(spatial_coverage_geom)
    spatial_areas = []
    spatial_coverage_geom.each do |geom|
      geo_json = RGeo::GeoJSON.decode(geom['geom4326'])
      if geo_json.geometry_type.to_s.downcase.eql?('point')
        spatial_areas << 0.0
      else
        bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geo_json)
        spatial_areas << (bbox.max_y - bbox.min_y)
      end
    end

    return nil if spatial_areas.empty?

    spatial_areas.sort.last
  end

  def translate_spatial_coverage_geom_to_global_facet(spatial_coverage_geom)
    return 'No Spatial Information' if spatial_coverage_geom.nil? || spatial_coverage_geom.empty?

    spatial_coverage_geom.each do |geom|
      geo_json = RGeo::GeoJSON.decode(geom['geom4326'])
      bbox_hash = NsidcJsonToSolr.bounding_box_hash(geo_json)
      return 'Global' if SolrStringFormat.box_global?(bbox_hash)
    end

    'Non Global'
  end

  def translate_spatial_coverage_geom_to_spatial_scope_facet(spatial_coverage_geom)
    scopes = []

    if spatial_coverage_geom.nil? || spatial_coverage_geom.empty?
      scopes << SolrStringFormat.get_spatial_scope_facet_with_bounding_box(nil)
    else
      spatial_coverage_geom.each do |geom|
        geo_json = RGeo::GeoJSON.decode(geom['geom4326'])
        bbox_hash = NsidcJsonToSolr.bounding_box_hash(geo_json)
        scopes << SolrStringFormat.get_spatial_scope_facet_with_bounding_box(bbox_hash)
      end
    end

    scopes.uniq
  end

  def translate_parameters(parameters_json)
    parameters = []
    parameters_json.each do |param_json|
      parameters.concat(generate_parameters_part_array(param_json))
    end
    parameters
  end

  def translate_parameters_to_string(parameters_json)
    parameters_strings = []
    parameters_json.each do |param_json|
      parameters_strings << generate_parameters_part_array(param_json).join(' > ')
    end
    parameters_strings.uniq!
  end

  def translate_parameters_to_facet_parameters(parameters_json)
    parameters_strings = translate_parameters_to_string(parameters_json)
    return [] if parameters_strings.nil?
    facet_params = []
    parameters_strings.each do |str|
      facet_params << SolrStringFormat.parameter_binning(str)
    end
    facet_params
  end

  def translate_json_string(json)
    json_string = []

    json.each do |item|
      json_string << generate_part_array(item).join(' > ')
    end

    json_string
  end

  def generate_parameters_part_array(json)
    gcmd_var_hash = json.select { |k, v| %w(category topic term variableLevel1 variableLevel2 variableLevel3 detailedVariable).include?(k) }
    generate_part_array(gcmd_var_hash)
  end

  def generate_part_array(json)
    parts =  []

    json.each do |k, v|
      parts << v unless v.to_s.empty?
    end

    parts
  end

  def self.bounding_box_hash(geometry)
    if geometry.geometry_type.to_s.downcase.eql?('point')
      return { west: geometry.x.to_s, south: geometry.y.to_s, east: geometry.x.to_s, north: geometry.y.to_s }
    else
      bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geometry)
      return { west: bbox.min_x.to_s, south: bbox.min_y.to_s, east: bbox.max_x.to_s, north: bbox.max_y.to_s }
    end
  end
end
# rubocop:disable ClassLength
