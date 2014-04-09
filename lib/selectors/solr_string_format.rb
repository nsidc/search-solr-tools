require 'date'

module SolrStringFormat

  FACET_TEMPORAL_DURATION = proc { |duration| SolrStringFormat.get_temporal_duration_facet(duration) }
  TEMPORAL_DURATION = proc { |start_time, end_time| SolrStringFormat.get_temporal_duration(start_time, end_time)}
  REDUCE_TEMPORAL_DURATION = proc { |values| SolrStringFormat.reduce_temporal_duration(values) }
  STRING_DATE = proc { |date| date_str date }
  FORMAT_BINNING = proc { |format| SolrStringFormat.format_binning format.text }
  PARAMETER_BINNING = proc { |param| SolrStringFormat.parameter_binning param.text }
  DATE = proc { |date | SolrStringFormat.date_str date.text }

  def self.get_spatial_facet(box)
    if box_invalid?(box)
      facet = 'No Spatial Information'
    elsif box_global?(box)
      facet = 'Global'
    else
      facet = 'Non Global'
    end
    facet
  end

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
      if end_time.to_s.empty? then end_time = Time.now end
      # datasets that cover just one day would have end_date - start_date = 0,
      # so we need to add 1 to make sure the duration is the actual number of
      # days; if the end date and start date are flipped in the metadata, a
      # negative duration doesn't make sense so use the absolute value
      duration = Integer((end_time - start_time).abs / 86400 ) + 1
    end
    duration
  end

  def self.get_temporal_duration_facet(duration)
    return 'No Temporal Information' if duration.nil?
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

  def self.get_spatial_scope_facet_with_bounding_box(bbox)
    if bbox.nil? || box_invalid?(bbox)
      facet = 'No Spatial Information'
    elsif box_global?(bbox)
      facet = 'Coverage from over 85 degrees North to -85 degrees South | Global'
    elsif box_local?(bbox)
      facet = 'Less than 1 degree of latitude change | Local'
    else
      facet = 'Between 1 and 170 degrees of latitude change | Regional'
    end
    facet
  end

  private

  def self.date_str(date)
    d = if date.is_a? String
          DateTime.parse(date.strip) rescue nil
        else
          date
        end
    "#{d.iso8601[0..-7]}Z" unless d.nil?
  end

  def self.date?(date)
    valid_date = if date.is_a? String
                   d = DateTime.parse(date.strip) rescue false
                   DateTime.valid_date?(d.year, d.mon, d.day) unless d.eql?(false)
                 end
    valid_date
  end

  MIN_DATE = '00010101'
  MAX_DATE = Time.now.strftime('%Y%m%d')

  def self.format_date_for_index(date_str, default)
    date_str = default unless date? date_str
    DateTime.parse(date_str).strftime('%C.%y%m%d')
  end

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

  def self.format_date_for_index(date_str, default)
    date_str = default unless date? date_str
    DateTime.parse(date_str).strftime('%C.%y%m%d')
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

  def self.ices_dataset_url(auth_id)
    'http://geo.ices.dk/geonetwork/srv/en/main.home?uuid=' + auth_id
  end

  def self.bin(mappings, term)
    mappings.each do |match_key, value|
      term.match(match_key) do
        return value
      end
    end

    nil
  end

  def self.box_invalid?(box)
    [:north, :south, :east, :west].any? { |d| box[d].nil? || box[d].empty? }
  end

  def self.box_global?(box)
    box[:south].to_f < -85.0 && box[:north].to_f > 85.0
  end

  def self.box_local?(box)
    distance = box[:north].to_f - box[:south].to_f
    distance < 1
  end
end