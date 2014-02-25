# Parameter mappings from GCMD string to search facet bins.
module NsidcParameterMapping
  MAPPING = {
      '.*Atmospheric Chemistry.*' => 'Atmospheric Chemistry',
      '.*Atmospheric Pressure.*' => 'Atmospheric Pressure',
      '.*Atmospheric Winds.*' => 'Atmospheric Winds',
      '.*Clouds.*' => 'Clouds',
      '.*Geochemistry.*' => 'Geochemistry',
      '.*Geomorphology.*' => 'Geomorphology',
      '.*Ice Core Records.*' => 'Ice Core Records',
      '.*Ocean Chemistry.*' => 'Ocean Chemistry',
      '.*Ocean Acoustics.*' => 'Ocean Acoustics',
      '.*Ocean Temperature.*' => 'Ocean Temperature',
      '.*Ocean Waves.*' => 'Ocean Waves',
      '.*Ocean Winds.*' => 'Ocean Winds',
      '.*Rocks/Minerals.*' => 'Rocks/Minerals',
      '.*Salinity/Density.*' => 'Salinity/Density',
      '.*Water Quality/Water Chemistry.*' => 'Water Quality/Water Chemistry',
      '.*Marine Sediments.*' => 'Marine Sediments',
      '.*Ocean/Lake Records.*' => 'Marine Sediments',

      # Topic mappings
      'EARTH SCIENCE > Biological Classification.*' => 'Biosphere',
      'EARTH SCIENCE > Biosphere.*' => 'Biosphere',
      'EARTH SCIENCE > Human Dimensions.*' => 'Human Dimensions',
  }
end