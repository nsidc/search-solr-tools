require 'rgeo/geo_json'
require './lib/selectors/helpers/bounding_box_util'
require './lib/selectors/helpers/iso_to_solr_format'

# Methods to translate  temporal coverage object to solr format values
module TranslateTemporalCoverage
  def self.translate_coverages(temporal_coverages_json)
    temporal_coverages = []
    temporal = []
    temporal_durations = []
    temporal_coverages_json.each do |coverage|
      start_time = Time.parse(coverage['start']) unless coverage['start'].to_s.empty?
      end_time = Time.parse(coverage['end']) unless coverage['end'].to_s.empty?
      temporal_durations << (SolrFormat.get_temporal_duration start_time, end_time)
      temporal_coverages << SolrFormat.temporal_display_str(start: (format_string(start_time)), end: ((format_string(end_time))))
      temporal << SolrFormat.temporal_index_str(start: start_time.to_s, end: end_time.to_s)
    end unless temporal_coverages_json.nil?
    max_temporal_duration = SolrFormat.reduce_temporal_duration temporal_durations
    facet = SolrFormat.get_temporal_duration_facet max_temporal_duration
    { 'temporal_coverages' => temporal_coverages, 'temporal_duration' => max_temporal_duration, 'temporal' => temporal, 'facet_temporal_duration' => facet  }
  end

  def self.format_string(value)
    value.to_s.empty? ? nil : value.strftime('%Y-%m-%d')
  end
end
