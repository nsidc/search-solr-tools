# frozen_string_literal: true

require 'rgeo/geo_json'

require 'search_solr_tools'
require_relative '../helpers/solr_format'
require_relative '../helpers/translate_temporal_coverage'
require_relative '../helpers/translate_spatial_coverage'

module SearchSolrTools
  module Translators
    # Translates NSIDC JSON format to Solr JSON add format
    class NsidcJsonToSolr
      PARAMETER_PARTS = %w[category topic term variableLevel1 variableLevel2 variableLevel3 detailedVariable].freeze

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def translate(json_doc)
        copy_keys = %w[title summary keywords brokered]
        temporal_coverage_values = Helpers::TranslateTemporalCoverage.translate_coverages json_doc['temporalCoverages']
        spatial_coverages = convert_spatial_coverages(json_doc['spatialCoverages'])

        solr_add_hash = json_doc.select { |k, _v| copy_keys.include?(k) }
        solr_add_hash.merge!(
          'authoritative_id'          => json_doc['authoritativeId'],
          'dataset_version'           => json_doc['majorVersion']['version'],
          'data_centers'              => Helpers::SolrFormat::DATA_CENTER_NAMES[:NSIDC][:long_name],
          'facet_data_center'         => "#{Helpers::SolrFormat::DATA_CENTER_NAMES[:NSIDC][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:NSIDC][:short_name]}",
          'cumulus'                   => json_doc['cumulus'],
          'authors'                   => translate_personnel_and_creators_to_authors(json_doc['personnel'], generate_data_citation_creators(json_doc['dataCitation'])),
          'topics'                    => translate_iso_topic_categories(json_doc['isoTopicCategories']),
          'parameters'                => translate_parameters(json_doc['parameters']),
          'full_parameters'           => translate_json_string(json_doc['parameters'], PARAMETER_PARTS),
          'facet_parameter'           => translate_parameters_to_facet_parameters(json_doc['parameters']),
          'platforms'                 => translate_json_string(json_doc['platforms']),
          'sensors'                   => translate_json_string(json_doc['instruments']),
          'facet_sensor'              => translate_sensor_to_facet_sensor(json_doc['instruments']),
          'published_date'            => (Helpers::SolrFormat.date_str json_doc['releaseDate']),
          'spatial_coverages'         => Helpers::TranslateSpatialCoverage.geojson_to_spatial_display_str(spatial_coverages),
          'spatial'                   => Helpers::TranslateSpatialCoverage.geojson_to_spatial_index_str(spatial_coverages),
          'spatial_area'              => Helpers::TranslateSpatialCoverage.geojson_to_spatial_area(spatial_coverages),
          'facet_spatial_coverage'    => Helpers::TranslateSpatialCoverage.geojson_to_global_facet(spatial_coverages),
          'facet_spatial_scope'       => Helpers::TranslateSpatialCoverage.geojson_to_spatial_scope_facet(spatial_coverages),
          'temporal_coverages'        => temporal_coverage_values['temporal_coverages'],
          'temporal_duration'         => temporal_coverage_values['temporal_duration'],
          'temporal'                  => temporal_coverage_values['temporal'],
          'facet_temporal_duration'   => temporal_coverage_values['facet_temporal_duration'],
          'last_revision_date'        => (Helpers::SolrFormat.date_str json_doc['lastRevisionDate']),
          'dataset_url'               => json_doc['datasetUrl'],
          'distribution_formats'      => json_doc['distributionFormats'],
          'facet_format'              => json_doc['distributionFormats'].empty? ? [Helpers::SolrFormat::NOT_SPECIFIED] : translate_format_to_facet_format(json_doc['distributionFormats']),
          'source'                    => %w[NSIDC ADE],
          'popularity'                => json_doc['popularity'],
          'data_access_urls'          => translate_data_access_urls(json_doc['dataAccessLinks']),
          'facet_sponsored_program'   => translate_short_long_names_to_facet_value(json_doc['internalDataCenters']),
          'facet_temporal_resolution' => translate_temporal_resolution_facet_values(json_doc['parameters']),
          'facet_spatial_resolution'  => translate_spatial_resolution_facet_values(json_doc['parameters']),
          'sponsored_programs'        => translate_internal_datacenters(json_doc['internalDataCenters']),
          'facet_featured'            => translate_featured(json_doc, spatial_coverages)
        )
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

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
          sensor_bin = Helpers::SolrFormat.facet_binning('sensor', json_entry['shortName'].to_s)
          facet_values << if sensor_bin.eql? json_entry['shortName']
                            "#{json_entry['longName']} | #{json_entry['shortName']}"
                          else
                            " | #{sensor_bin}"
                          end
        end
        facet_values
      end

      def translate_temporal_resolution_facet_values(parameters_json)
        temporal_resolutions = []
        parameters_json.each do |param_json|
          binned_temporal_res = Helpers::SolrFormat.resolution_value(param_json['temporalResolution'], :find_index_for_single_temporal_resolution_value, Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)
          temporal_resolutions << binned_temporal_res unless binned_temporal_res.to_s.empty?
        end
        temporal_resolutions.flatten.uniq
      end

      def translate_spatial_resolution_facet_values(parameters_json)
        spatial_resolutions = []
        parameters_json.each do |param_json|
          binned_res = Helpers::SolrFormat.resolution_value(param_json['spatialYResolution'], :find_index_for_single_spatial_resolution_value, Helpers::SolrFormat::SPATIAL_RESOLUTION_FACET_VALUES)
          spatial_resolutions << binned_res unless binned_res.to_s.empty?
        end
        spatial_resolutions.flatten.uniq
      end

      def translate_iso_topic_categories(iso_topic_categories_json)
        iso_topic_categories_json&.map { |t| t['name'] }
      end

      def translate_data_access_urls(json)
        values = []
        return values if json.nil?

        json.each do |json_entry|
          link_display = json_entry['displayText'].nil? ? '' : json_entry['displayText']
          link_type = json_entry['type'].nil? ? '' : json_entry['type']
          link_uri = json_entry['uri'].nil? ? '' : json_entry['uri']
          link_desc = json_entry['description'].nil? ? '' : json_entry['description']

          values << "#{link_display} | #{link_type} | #{link_uri} | #{link_desc}"
        end
        values
      end

      def translate_internal_datacenters(json)
        values = []
        return values if json.nil?

        json.each do |json_entry|
          short_name = json_entry['shortName'].nil? ? '' : json_entry['shortName']
          values << short_name
        end
        values
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
        author_set = (personnel_json.to_a | creator_json.to_a)

        authors = author_set.map do |author|
          first  = author['firstName'].to_s
          middle = author['middleName'].to_s
          last   = author['lastName'].to_s

          full = [first, middle, last].reject(&:empty?)
          full.join(' ').strip
        end

        authors.reject! do |author|
          author.empty? || author == 'NSIDC User Services'
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
          facet_params << Helpers::SolrFormat.parameter_binning(str)
        end
        facet_params
      end

      def translate_format_to_facet_format(format_json)
        return [] if format_json.nil?

        facet_format = []

        format_json.each do |format|
          facet_format << Helpers::SolrFormat.facet_binning('format', format)
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

      def translate_featured(json, spatial_coverages)
        facet_featured = []

        # Add the Earthdata Cloud feature
        # facet_featured << 'Available in NASA Earthdata Cloud' if json['cumulus']
        facet_featured << 'In Earthdata Cloud' if json['cumulus']

        # Add the "Global" spatial coverage to this facet
        global = Helpers::TranslateSpatialCoverage.geojson_to_global_facet(spatial_coverages)
        facet_featured << global unless global.nil?

        facet_featured
      end

      def generate_data_citation_creators(data_citation)
        data_citation.nil? ? [] : data_citation['creators']
      end

      def generate_part_array(json, limit_values = nil)
        parts = []
        json = json.select { |k, _v| limit_values.include?(k) } unless limit_values.nil? || limit_values.empty?

        json.each do |_k, v|
          parts << v unless v.to_s.empty?
        end

        parts
      end
    end
  end
end
