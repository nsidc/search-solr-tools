require 'rgeo/geo_json'

require_relative './bounding_box_util'
require_relative './iso_to_solr_format'

# Methods to translate temporal coverage object to solr format values
module TranslateTemporalCoverage
  def self.translate_coverages(temporal_coverages_json)
    temporal_coverages = temporal_coverages_json.to_a.map do |coverage|
      start_time = time_string(coverage, 'start')
      end_time = time_string(coverage, 'end')

      [
        SolrFormat.temporal_index_str(start: start_time.to_s, end: end_time.to_s),
        SolrFormat.temporal_display_str(start: format_string(start_time), end: format_string(end_time)),
        SolrFormat.get_temporal_duration(start_time, end_time)
      ]
    end.transpose

    temporal_index_str = temporal_coverages[0] || []
    temporal_display   = temporal_coverages[1] || []
    temporal_durations = temporal_coverages[2] || []

    max_temporal_duration = SolrFormat.reduce_temporal_duration(temporal_durations)
    facet = SolrFormat.get_temporal_duration_facet(max_temporal_duration)

    { 'temporal_coverages' => temporal_display, 'temporal_duration' => max_temporal_duration, 'temporal' => temporal_index_str, 'facet_temporal_duration' => facet  }
  end

  def self.format_string(value)
    value.to_s.empty? ? nil : value.strftime('%Y-%m-%d')
  end

  def self.time_string(coverage, key)
    Time.parse(coverage[key]) unless coverage[key].to_s.empty?
  end
end
