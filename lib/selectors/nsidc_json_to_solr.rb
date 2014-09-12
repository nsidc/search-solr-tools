# rubocop:disable ClassLength
require 'rgeo/geo_json'
require './lib/selectors/helpers/bounding_box_util'
require './lib/selectors/helpers/iso_to_solr_format'
require './lib/selectors/helpers/translate_spatial_coverage'
require './lib/selectors/helpers/translate_temporal_coverage'

# Translates NSIDC JSON format to Solr JSON add format
class NsidcJsonToSolr
  PARAMETER_PARTS = %w(category topic term variableLevel1 variableLevel2 variableLevel3 detailedVariable)

# rubocop:disable MethodLength
  def translate(json_doc)
    copy_keys = %w(title summary keywords brokered)
    temporal_coverage_values = TranslateTemporalCoverage.translate_coverages json_doc['temporalCoverages']
    spatial_coverages = convert_spatial_coverages(json_doc['spatialCoverages'])

    solr_add_hash = json_doc.select { |k, v| copy_keys.include?(k) }
    solr_add_hash.merge!(
      'authoritative_id' => json_doc['authoritativeId'],
      'dataset_version' => json_doc['majorVersion']['version'],
      'data_centers' => SolrFormat::DATA_CENTER_NAMES[:NSIDC][:long_name],
      'facet_data_center' => "#{SolrFormat::DATA_CENTER_NAMES[:NSIDC][:long_name]} | #{SolrFormat::DATA_CENTER_NAMES[:NSIDC][:short_name]}",
      'authors' => translate_personnel_and_creators_to_authors(json_doc['personnel'], generate_data_citation_creators(json_doc['dataCitation'])),
      'topics' => translate_iso_topic_categories(json_doc['isoTopicCategories']),
      'parameters' => translate_parameters(json_doc['parameters']),
      'full_parameters' => translate_json_string(json_doc['parameters'], PARAMETER_PARTS),
      'facet_parameter' => translate_parameters_to_facet_parameters(json_doc['parameters']),
      'platforms' => translate_json_string(json_doc['platforms']),
      'sensors' => translate_json_string(json_doc['instruments']),
      'facet_sensor' => translate_sensor_to_facet_sensor(json_doc['instruments']),
      'published_date' => (SolrFormat.date_str json_doc['releaseDate']),
      'spatial_coverages' => TranslateSpatialCoverage.geojson_to_spatial_display_str(spatial_coverages),
      'spatial' => TranslateSpatialCoverage.geojson_to_spatial_index_str(spatial_coverages),
      'spatial_area' => TranslateSpatialCoverage.geojson_to_spatial_area(spatial_coverages),
      'facet_spatial_coverage' => TranslateSpatialCoverage.geojson_to_global_facet(spatial_coverages),
      'facet_spatial_scope' => TranslateSpatialCoverage.geojson_to_spatial_scope_facet(spatial_coverages),
      'temporal_coverages' => temporal_coverage_values['temporal_coverages'],
      'temporal_duration' => temporal_coverage_values['temporal_duration'],
      'temporal' => temporal_coverage_values['temporal'],
      'facet_temporal_duration' => temporal_coverage_values['facet_temporal_duration'],
      'last_revision_date' => (SolrFormat.date_str json_doc['lastRevisionDate']),
      'dataset_url' => json_doc['datasetUrl'],
      'distribution_formats' => json_doc['distributionFormats'],
      'facet_format' => (json_doc['distributionFormats'].empty?) ? [SolrFormat::NOT_SPECIFIED] : translate_format_to_facet_format(json_doc['distributionFormats']),
      'source' => %w(NSIDC ADE),
      'popularity' => json_doc['popularity'],
      'facet_sponsored_program' => translate_short_long_names_to_facet_value(json_doc['internalDataCenters']),
      'facet_temporal_resolution' => translate_temporal_resolution_facet_values(json_doc['parameters']),
      'facet_spatial_resolution' => translate_spatial_resolution_facet_values(json_doc['parameters'])
    )
  end
# rubocop:enable MethodLength

  def convert_spatial_coverages(nsidc_geom)
    geometries = []
    nsidc_geom.each do |entry|
      geometries << RGeo::GeoJSON.decode(entry['geom4326'])
    end
    geometries
  end

  def translate_sensor_to_facet_sensor(json)
    facet_values = []
    return facet_values if json.nil?
    json.each do |json_entry|
      sensor_bin = SolrFormat.facet_binning('sensor', json_entry['shortName'].to_s)
      if sensor_bin.eql? json_entry['shortName']
        facet_values << "#{json_entry['longName'].to_s} | #{json_entry['shortName'].to_s}"
      else
        facet_values << " | #{sensor_bin}"
      end
    end
    facet_values
  end

  def translate_temporal_coverage_values(temporal_coverages_json)
    temporal_coverages = []
    temporal = []
    temporal_durations = []
    temporal_coverages_json.each do |coverage|
      start_time = Time.parse(coverage['start']) unless coverage['start'].to_s.empty?
      end_time = Time.parse(coverage['end']) unless coverage['end'].to_s.empty?
      temporal_durations << (SolrFormat.get_temporal_duration start_time, end_time)
      temporal_coverages << SolrFormat.temporal_display_str(start: (start_time.to_s.empty? ? nil : start_time.strftime('%Y-%m-%d')), end: (end_time.to_s.empty? ? nil : end_time.strftime('%Y-%m-%d')))
      temporal << SolrFormat.temporal_index_str(start: start_time.to_s, end: end_time.to_s)
    end unless temporal_coverages_json.nil?
    max_temporal_duration = SolrFormat.reduce_temporal_duration temporal_durations
    facet = SolrFormat.get_temporal_duration_facet max_temporal_duration
    { 'temporal_coverages' => temporal_coverages, 'temporal_duration' => max_temporal_duration, 'temporal' => temporal, 'facet_temporal_duration' => facet  }
  end

  def translate_temporal_resolution_facet_values(parameters_json)
    temporal_resolutions = []
    parameters_json.each do |param_json|
      binned_temporal_res = SolrFormat.resolution_value(param_json['temporalResolution'], :find_index_for_single_temporal_resolution_value, SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)
      temporal_resolutions << binned_temporal_res unless binned_temporal_res.to_s.empty?
    end
    temporal_resolutions.flatten.uniq
  end

  def translate_spatial_resolution_facet_values(parameters_json)
    spatial_resolutions = []
    parameters_json.each do |param_json|
      binned_res = SolrFormat.resolution_value(param_json['spatialYResolution'], :find_index_for_single_spatial_resolution_value, SolrFormat::SPATIAL_RESOLUTION_FACET_VALUES)
      spatial_resolutions << binned_res unless binned_res.to_s.empty?
    end
    spatial_resolutions.flatten.uniq
  end

  def translate_iso_topic_categories(iso_topic_categories_json)
    iso_topic_categories_json.map { |t| t['name'] } unless iso_topic_categories_json.nil?
  end

  def translate_short_long_names_to_facet_value(json)
    facet_values = []
    return facet_values if json.nil?
    json.each do |json_entry|
      long_name = json_entry['longName'].nil? ? '' : json_entry['longName']
      short_name = json_entry['shortName'].nil? ? '' : json_entry['shortName']

      facet_values << "#{long_name} | #{short_name}"
    end
    facet_values
  end

  def translate_personnel_and_creators_to_authors(personnel_json, creator_json)
    authors = []
    contact_array = personnel_json.to_a | creator_json.to_a
    contact_array.each do |person|
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
    authors.uniq
  end

  def translate_parameters(parameters_json)
    parameters = []
    parameters_json.each do |param_json|
      parameters.concat(generate_part_array(param_json, PARAMETER_PARTS))
    end
    parameters
  end

  def translate_parameters_to_facet_parameters(parameters_json)
    parameters_strings = translate_json_string(parameters_json, PARAMETER_PARTS)
    return [] if parameters_strings.nil?
    facet_params = []
    parameters_strings.each do |str|
      facet_params << SolrFormat.parameter_binning(str)
    end
    facet_params
  end

  def translate_format_to_facet_format(format_json)
    return [] if format_json.nil?

    facet_format = []

    format_json.each do |format|
      facet_format << SolrFormat.facet_binning('format', format)
    end
    facet_format
  end

  def translate_json_string(json, limit_values = nil)
    json_strings = []

    json.each do |item|
      json_string = generate_part_array(item, limit_values).join(' > ')
      json_strings << json_string unless json_string.empty?
    end

    json_strings.uniq
  end

  def generate_data_citation_creators(data_citation)
    data_citation.nil? ? creators = [] : creators = data_citation['creators']
    creators
  end

  def generate_part_array(json, limit_values = nil)
    parts =  []
    json = json.select { |k, v| limit_values.include?(k) } unless limit_values.nil? || limit_values.empty?

    json.each do |k, v|
      parts << v unless v.to_s.empty?
    end

    parts
  end
end
# rubocop:disable ClassLength
