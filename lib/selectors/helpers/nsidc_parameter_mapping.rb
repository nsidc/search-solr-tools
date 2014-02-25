module NsidcParameterMapping
  MAPPING = {
      ##Cryosphere, Terrestrial Hydrosphere and sea ice terms, written to catch similar matchings across topics.
      #'.*Albedo.*' => 'Albedo',
      #'.*Depth Hoar.*' => 'Depth Hoar',
      #'.*Freeze/Thaw.*' => 'Freeze/Thaw',
      #'.*Frost.*' => 'Frost',
      #'.*Heat Flux.*' => 'Heat Flux',
      #'.*Icebergs.*' => 'Icebergs',
      #'.*Ice Deformation.*' => 'Ice Deformation',
      #'.*Ice Depth/Thickness.*' => 'Ice Depth/Thickness',
      #'.*Ice Edges.*' => 'Ice Edges',
      #'.*Ice Extent.*' => 'Ice Extent',
      #'.*Ice Floes.*' => 'Ice Floes',
      #'.*Ice Growth/Melt.*' => 'Ice Growth/Melt',
      #'.*Ice Motion.*' => 'Ice Motion',
      #'.*Ice Roughness.*' => 'Ice Roughness',
      #'.*Ice Temperature.*' => 'Ice Temperature',
      #'.*Ice Types.*' => 'Ice Types',
      #'.*Ice Velocity.*' => 'Ice Velocity',
      #'.*Isotopes.*' => 'Isotopes',
      #'.*Lake Ice.*' => 'Lake Ice',
      #'.*Leads.*' => 'Leads',
      #'.*Pack Ice.*' => 'Pack Ice',
      #'.*Permafrost.*' => 'Permafrost',
      #'.*Polynyas.*' => 'Polynyas',
      #'.*Reflectance.*' => 'Reflectance',
      #'.*River Ice.*' => 'River Ice',
      #'.*Salinity.*' => 'Salinity',
      #'.*Sea Ice Age.*' => 'Sea Ice Age',
      #'.*Sea Ice Concentration.*' => 'Sea Ice Concentration',
      #'.*Sea Ice Elevation.*' => 'Sea Ice Elevation',
      #'.*Sea Ice Motion.*' => 'Sea Ice Motion',
      #'.*Snow Cover.*' => 'Snow Cover',
      #'.*Snow Density.*' => 'Snow Density',
      #'.*Snow Depth.*' => 'Snow Depth',
      #'.*Snow Energy Balance.*' => 'Snow Energy Balance',
      #'.*Snow Facies.*' => 'Snow Facies',
      #'.*Snow/Ice Chemistry.*' => 'Snow/Ice Chemistry',
      #'.*Snow/Ice Temperature.*' => 'Snow/Ice Temperature',
      #'.*Snow Melt.*' => 'Snow Melt',
      #'.*Snow Stratigraphy.*' => 'Snow Stratigraphy',
      #'.*Snow Water Equivalent.*' => 'Snow Water Equivalent',
      #
      ##Other mappings
      #'.*Glaciers.*Glaciers.*' => 'Glaciers',
      #
      ##Term mappings
      #'Cryosphere > Sea Ice.*' => 'Sea Ice',
      #'Oceans > Sea Ice.*' => 'Sea Ice',

      #Topic mappings
      'EARTH SCIENCE > Biological Classification.*' => 'Biosphere',
      'EARTH SCIENCE > Biosphere.*' => 'Biosphere',
      'EARTH SCIENCE > Human Dimensions.*' => 'Human Dimensions',
  }
end