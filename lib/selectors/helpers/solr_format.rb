require 'date'
require 'iso8601'
require './lib/selectors/helpers/bounding_box_util'

#  Methods for generating formatted values that can be indexed by SOLR
module SolrFormat
  DATA_CENTER_NAMES = {
      NSIDC: { short_name: 'NSIDC', long_name: 'National Snow and Ice Data Center' },
      CISL: { short_name: 'ACADIS Gateway', long_name: 'Advanced Cooperative Arctic Data and Information Service' },
      ECHO: { short_name: 'NASA ECHO', long_name: 'NASA Earth Observing System (EOS) Clearing House (ECHO)' },
      EOL: { short_name: 'UCAR/NCAR EOL', long_name: 'UCAR/NCAR - Earth Observing Laboratory' },
      ICES: { short_name: 'ICES', long_name: 'International Council for the Exploration of the Sea' },
      NMI: { short_name: 'Met.no', long_name: 'Norwegian Meteorological Institute' },
      NODC: { short_name: 'NOAA NODC', long_name: 'NOAA National Oceanographic Data Center' },
      RDA: { short_name: 'UCAR/NCAR RDA', long_name: 'UCAR/NCAR Research Data Archive' },
      EOL: { short_name: 'UCAR/NCAR EOL', long_name: 'UCAR/NCAR - Earth Observing Laboratory' },
      USGS: { short_name: 'USGS ScienceBase', long_name: 'U.S. Geological Survey ScienceBase' },
      BCODMO: { short_name: 'BCO-DMO', long_name: 'Biological and Chemical Oceanography Data Management Office' },
      TDAR: { short_name: 'TDAR', long_name: 'Digital Archaeological Record' },
      PDC: { short_name: 'PDC', long_name: 'Polar Data Catalog' }
  }

  NOT_SPECIFIED = 'Not specified'

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

  SPATIAL_RESOLUTION_FACET_VALUES = ['0 - 500 m', '501 m - 1 km', '2 - 5 km', '6 - 15 km', '16 - 30 km', '>30 km']
  SPATIAL_0_500_INDEX = 0
  SPATIAL_501_1_INDEX = 1
  SPATIAL_2_5_INDEX = 2
  SPATIAL_6_15_INDEX = 3
  SPATIAL_16_30_INDEX = 4
  SPATIAL_GREATER_30_INDEX = 5

  REDUCE_TEMPORAL_DURATION = proc { |values| reduce_temporal_duration(values) }
  DATE = proc { |date | date_str date.text }

  HTTP_URL_FORMAT = proc { |url| url =~ %r{//} ? url : "http://#{ url }" }

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

  def self.facet_binning(type, format_string)
    binned_facet = bin(FacetConfiguration.get_facet_bin(type), format_string)
    if binned_facet.nil?
      return format_string
    elsif binned_facet.eql?('exclude')
      return nil
    else
      return binned_facet
    end

    nil
  end

  def self.parameter_binning(parameter_string)
    binned_parameter = bin(FacetConfiguration.get_facet_bin('parameter'), parameter_string)
    # use variable_level_1 if no mapping exists
    if binned_parameter.nil?
      parts = parameter_string.split '>'
      return parts[3].strip if parts.length >= 4
    else
      return binned_parameter
    end

    nil
  end

  def self.resolution_value(resolution, find_index_method, resolution_values)
    return NOT_SPECIFIED if resolution.to_s.empty?

    if resolution['type'] == 'single'
      return NOT_SPECIFIED if resolution['resolution'].to_s.empty?
      i = send(find_index_method, resolution['resolution'])
      return resolution_values[i]
    elsif resolution['type'] == 'range'
      return NOT_SPECIFIED if resolution['min_resolution'].to_s.empty?
      i = send(find_index_method, resolution['min_resolution'])
      j = send(find_index_method, resolution['max_resolution'])
      return resolution_values[i..j]
    else
      return NOT_SPECIFIED
    end
  end

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
    mappings.each do |mapping|
      term.match(mapping['pattern']) do
        return mapping['mapping']
      end
    end
    nil
  end

  # rubocop:disable MethodLength, CyclomaticComplexity
  def self.find_index_for_single_temporal_resolution_value(string_duration)
    iso8601_duration = ISO8601::Duration.new(string_duration)
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

  def self.find_index_for_single_spatial_resolution_value(string_duration)
    value, units = string_duration.split(' ')
    value = value.to_f
    if units == 'deg'
      if value <= 0.05
        return SPATIAL_2_5_INDEX
      elsif value < 0.5 # && value > .05
        return SPATIAL_16_30_INDEX
      else # value >= .5
        return SPATIAL_GREATER_30_INDEX
      end
    elsif units == 'm'
      if value <= 500
        return SPATIAL_0_500_INDEX
      elsif value <= 1_000 # && value > 500
        return SPATIAL_501_1_INDEX
      elsif value <= 5_000 # && value > 1000
        return SPATIAL_2_5_INDEX
      elsif value <= 15_000 # && value > 5000
        return SPATIAL_6_15_INDEX
      elsif value <= 30_000 # && value > 15000
        return SPATIAL_16_30_INDEX
      else # value > 30000
        return SPATIAL_GREATER_30_INDEX
      end
    else
      return nil
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
