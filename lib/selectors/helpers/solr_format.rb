require 'date'
require 'iso8601'
require './lib/selectors/helpers/bounding_box_util'

#  Methods for generating formatted values that can be indexed by SOLR
module SolrFormat
  DATA_CENTER_LONG_NAME = 'National Snow and Ice Data Center'
  DATA_CENTER_SHORT_NAME = 'NSIDC'
  TEMPORAL_RESOLUTION_FACET_VALUES = %w(Subhourly Hourly Subdaily Daily Weekly Submonthly Monthly Subyearly Yearly Multiyearly)
  NOT_SPECIFIED = 'Not specified'

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

  REDUCE_TEMPORAL_DURATION = proc { |values| SolrFormat.reduce_temporal_duration(values) }
  DATE = proc { |date | SolrFormat.date_str date.text }

  def self.temporal_display_str(date_range)
    temporal_str = "#{date_range[:start]}"
    temporal_str += ",#{date_range[:end]}" unless date_range[:end].nil?
    temporal_str
  end

  # returns the temporal duration in days; returns -1 if there is not a valid
  # start date
  def self.get_temporal_duration(start_time, end_time)
    if start_time.to_s.empty?
      duration = nil
    else
      end_time = Time.now if end_time.to_s.empty?
      # datasets that cover just one day would have end_date - start_date = 0,
      # so we need to add 1 to make sure the duration is the actual number of
      # days; if the end date and start date are flipped in the metadata, a
      # negative duration doesn't make sense so use the absolute value
      duration = Integer((end_time - start_time).abs / 86_400) + 1
    end
    duration
  end

  def self.get_temporal_duration_facet(duration)
    return NOT_SPECIFIED if duration.nil?
    years = duration.to_i / 365
    temporal_duration_range(years)
  end

  # We are indexing date ranges a spatial coordinates.
  # This means we have to convert dates into the format YY.YYMMDD which can be stored in the standard lat/long space
  # For example: 2013-01-01T00:00:00Z to 2013-01-31T00:00:00Z will be converted to 20.130101, 20.130131.
  # See http://wiki.apache.org/solr/SpatialForTimeDurations
  def self.temporal_index_str(date_range)
    "#{format_date_for_index date_range[:start], MIN_DATE} #{format_date_for_index(date_range[:end], MAX_DATE)}"
  end

  def self.reduce_temporal_duration(values)
    values.map { |v| Integer(v) rescue nil }.compact.max
  end

  def self.format_binning(format_string)
    binned_format = bin(NsidcFormatMapping::MAPPING, format_string)

    # use metadata format if no mapping exists
    if binned_format.nil?
      return format_string
    elsif binned_format.eql?('exclude')
      return nil
    else
      return binned_format
    end

    nil
  end

  def self.parameter_binning(parameter_string)
    binned_parameter = bin(NsidcParameterMapping::MAPPING, parameter_string)

    # use variable_level_1 if no mapping exists
    if binned_parameter.nil?
      parts = parameter_string.split '>'
      return parts[3].strip if parts.length >= 4
    else
      return binned_parameter
    end

    nil
  end

  # rubocop:disable CyclomaticComplexity
  def self.temporal_resolution_value(temporal_resolution)
    return SolrFormat::NOT_SPECIFIED if temporal_resolution.nil? || temporal_resolution.empty?

    if temporal_resolution['type'] == 'single'
      return SolrFormat::NOT_SPECIFIED if temporal_resolution['resolution'].nil? || temporal_resolution['resolution'].empty?
      i = find_index_for_single_temporal_resolution_value ISO8601::Duration.new(temporal_resolution['resolution'])
      return SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES[i]
    elsif temporal_resolution['type'] == 'range'
      return SolrFormat::NOT_SPECIFIED if temporal_resolution['min_resolution'].nil? || temporal_resolution['min_resolution'].empty?
      i = find_index_for_single_temporal_resolution_value ISO8601::Duration.new(temporal_resolution['min_resolution'])
      j = find_index_for_single_temporal_resolution_value ISO8601::Duration.new(temporal_resolution['max_resolution'])
      return SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES[i..j]
    else
      return SolrFormat::NOT_SPECIFIED
    end
  end
  # rubocop:enable CyclomaticComplexity

  def self.get_spatial_scope_facet_with_bounding_box(bbox)
    if bbox.nil? || BoundingBoxUtil.box_invalid?(bbox)
      return nil
    elsif BoundingBoxUtil.box_global?(bbox)
      facet = 'Coverage from over 85 degrees North to -85 degrees South | Global'
    elsif BoundingBoxUtil.box_local?(bbox)
      facet = 'Less than 1 degree of latitude change | Local'
    else
      facet = 'Between 1 and 170 degrees of latitude change | Regional'
    end
    facet
  end

  def self.date_str(date)
    d = if date.is_a? String
          DateTime.parse(date.strip) rescue nil
        else
          date
        end
    "#{d.iso8601[0..-7]}Z" unless d.nil?
  end

  private

  MIN_DATE = '00010101'
  MAX_DATE = Time.now.strftime('%Y%m%d')

  def self.bin(mappings, term)
    mappings.each do |match_key, value|
      term.match(match_key) do
        return value
      end
    end

    nil
  end

  # rubocop:disable MethodLength, CyclomaticComplexity
  def self.find_index_for_single_temporal_resolution_value(iso8601_duration)
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

  # takes a temporal_duration in years, returns a string representing the range
  # for faceting
  def self.temporal_duration_range(years)
    range = []

    range.push '< 1 year' if years >= 0 && years < 1
    range.push '1+ years' if years >= 1
    range.push '5+ years' if years >= 5
    range.push '10+ years' if years >= 10

    range
  end

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
end
