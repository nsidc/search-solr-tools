require 'nsidc_json_to_solr'

describe NsidcJsonToSolr do
  before :each do
    @translator = described_class.new
  end

  it 'generates temporal values from NSIDC JSON' do
    temporal_coverages_json = [{ 'start' => '1986-12-14T00:00:00-07:00', 'end' => '1992-11-13T00:00:00-07:00' },
                               { 'start' => '', 'end' => '1992-01-18T00:00:00-07:00' },
                               { 'start' => '', 'end' => '' },
                               { 'start' => '1986-12-01T00:00:00-04:00', 'end' => '1986-12-02T00:00:00-04:00' }]
    temporal_values = @translator.generate_temporal_coverage_values(temporal_coverages_json)
    temporal_values['temporal_coverages'][0].should eql('1986-12-14,1992-11-13')
    temporal_values['temporal_duration'].should eql 2162
    temporal_values['temporal'][0].should eql '19.861214 19.921113'
    temporal_values['facet_temporal_duration'].should eql ['1+ years', '5+ years']
  end

  it 'generates temporal value defaults when there are none present in NSIDC JSON' do
    temporal_values = @translator.generate_temporal_coverage_values([])
    temporal_values['temporal_coverages'].should eql []
    temporal_values['temporal_duration'].should eql nil
    temporal_values['temporal'].should eql []
    temporal_values['facet_temporal_duration'].should eql 'No Temporal Information'
  end

  it 'generates a temporal duration value based on the longest single temporal coverage' do
    temporal_coverages_json = [{ 'start' => '1956-01-01T00:00:00-07:00', 'end' => '1964-01-01T00:00:00-07:00' },
                               { 'start' => '1994-01-01T00:00:00-07:00', 'end' => '1996-01-01T00:00:00-07:00' }]
    temporal_values = @translator.generate_temporal_coverage_values(temporal_coverages_json)
    temporal_values['temporal_duration'].should eql 2923
    temporal_values['facet_temporal_duration'].should eql ['1+ years', '5+ years']
  end

  it 'generates correct start values when no start date is specified' do
    temporal_coverages_json = [{ 'start' => '', 'end' => '1992-01-01T00:00:00-07:00' }]
    temporal_values = @translator.generate_temporal_coverage_values(temporal_coverages_json)
    temporal_values['temporal_coverages'].should eql [',1992-01-01']
    temporal_values['temporal_duration'].should eql nil
    temporal_values['temporal'].should eql ['00.010101 19.920101']
    temporal_values['facet_temporal_duration'].should eql 'No Temporal Information'
  end

  it 'translates NSIDC JSON date to SOLR format iso8601 date' do
    date = '2013-03-12T21:18:12-06:00'
    (SolrFormat.date_str date).should eql '2013-03-12T21:18:12Z'
  end

  it 'translates NSIDC internal data center to facet_sponsored_program string' do
    internal_datacenters_json = [{ 'shortName' => 'NASA DAAC', 'longName' => 'NASA DAAC at the National Snow and Ice Data Center', 'url' => 'http://nsidc.org/daac/index.html' },
                                 { 'shortName' => 'NOAA @ NSIDC', 'longName' => 'NSIDC National Oceanic and Atmospheric Administration', 'url' => 'http://nsidc.org/noaa/' }]
    facet_values = @translator.translate_internal_data_centers_to_facet_sponsored_program(internal_datacenters_json)
    facet_values[0].should eql 'NASA DAAC at the National Snow and Ice Data Center | NASA DAAC'
    facet_values[1].should eql 'NSIDC National Oceanic and Atmospheric Administration | NOAA @ NSIDC'
  end

  it 'translates NSIDC personnel json to authors list' do
    personnel_json = [{ 'role' => 'technical contact', 'firstName' => 'NSIDC', 'middleName' => '', 'lastName' => 'User Services' },
                      { 'role' => 'investigator', 'firstName' => 'Claire', 'middleName' => 'L.', 'lastName' => 'Parkinson' },
                      { 'role' => 'investigator', 'firstName' => 'Per', 'middleName' => '', 'lastName' => 'Gloersen' },
                      { 'role' => 'investigator', 'firstName' => 'H. Jay', 'middleName' => '', 'lastName' => 'Zwally' }]

    authors = @translator.translate_personnel_to_authors personnel_json
    authors[0].should_not include('NSIDC User Services')
    authors[0].should eql('Claire L. Parkinson')
    authors[1].should eql('Per Gloersen')
    authors[2].should eql('H. Jay Zwally')
  end

  it 'translates NSIDC parameters json to parameters' do
    parameters_json = [{ 'name' => 'test detail', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => 'test detail' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'ignore name', 'temporalResolution' => '', 'category' => '', 'topic' => '', 'term' => '', 'variableLevel1' => '', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' }]

    params = @translator.translate_parameters parameters_json
    params.should include('EARTH SCIENCE')
    params.should include('Oceans')
    params.should include('Sea Ice')
    params.should include('Sea Ice Concentration')
    params.should include('test detail')
    params.should_not include('')
  end

  it 'translates NSIDC parameters json to parameter strings' do
    parameters_json = [{ 'name' => 'test detail', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => 'test detail' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'ignore name', 'temporalResolution' => '', 'category' => '', 'topic' => '', 'term' => '', 'variableLevel1' => '', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' }]

    params = @translator.translate_parameters_to_string parameters_json
    params.should include('EARTH SCIENCE > Cryosphere > Sea Ice > Sea Ice Concentration > test detail')
    params.should include('EARTH SCIENCE > Cryosphere > Sea Ice > Sea Ice Concentration')
    params.should include('EARTH SCIENCE > Oceans > Sea Ice > Sea Ice Concentration')
    params.should_not include ''
    params.length.should eql 3
  end

  it 'translates NSIDC-0192 paramters json to parameter strings' do
    parameters_json = [{ 'name' => 'Ice Extent', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Ice Extent', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Ice Extent', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Ice Extent', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => '', 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' }]

    params = @translator.translate_parameters_to_string parameters_json
    params.should include('EARTH SCIENCE > Cryosphere > Sea Ice > Ice Extent')
    params.should include('EARTH SCIENCE > Oceans > Sea Ice > Ice Extent')
    params.should include('EARTH SCIENCE > Cryosphere > Sea Ice > Sea Ice Concentration')
    params.should include('EARTH SCIENCE > Oceans > Sea Ice > Sea Ice Concentration')
    params.should_not include ''
    params.length.should eql 4
  end

  it 'translates G00799 parameters to parameter string' do
    parameters_json = [{ 'name' => 'Ice Extent', 'temporalResolution' => { 'type' => 'single', 'resolution' => 'P1M' }, 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Ice Extent', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Ice Extent', 'temporalResolution' => { 'type' => 'single', 'resolution' => 'P1M' }, 'category' => 'EARTH SCIENCE', 'topic' => 'Terrestrial Hydrosphere', 'term' => 'Snow/Ice', 'variableLevel1' => 'Ice Extent', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Ice Extent', 'temporalResolution' => { 'type' => 'single', 'resolution' => 'P1M' }, 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Ice Extent', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => { 'type' => 'single', 'resolution' => 'P1M' }, 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'name' => 'Sea Ice Concentration', 'temporalResolution' => { 'type' => 'single', 'resolution' => 'P1M' }, 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' }]

    params = @translator.translate_parameters_to_string parameters_json
    params.should include('EARTH SCIENCE > Cryosphere > Sea Ice > Ice Extent')
    params.should include('EARTH SCIENCE > Terrestrial Hydrosphere > Snow/Ice > Ice Extent')
    params.should include('EARTH SCIENCE > Oceans > Sea Ice > Ice Extent')
    params.should include('EARTH SCIENCE > Cryosphere > Sea Ice > Sea Ice Concentration')
    params.should include('EARTH SCIENCE > Oceans > Sea Ice > Sea Ice Concentration')
  end

  it 'translates GeoJSON polygon to spatial display str' do
    spatial_coverages_json = [{ 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, 90.0], [180.0, 90.0], [180.0, 30.98], [-180.0, 30.98], [-180.0, 90.0]]] } },
                              { 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, -39.23], [180.0, -39.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -39.23]]] } }]
    spatial_display_strs = @translator.translate_spatial_coverage_geom_to_spatial_display_str(spatial_coverages_json)
    spatial_display_strs.length.should eql 2
    spatial_display_strs[0].should eql '30.98 -180.0 90.0 180.0'
    spatial_display_strs[1].should eql '-90.0 -180.0 -39.23 180.0'
  end

  it 'translates GeoJSON point to spatial display str' do
    spatial_coverages_json = [{ 'geom4326' => { 'type' => 'Point', 'coordinates' => [166.0, -85.0] } }]
    spatial_display_strs = @translator.translate_spatial_coverage_geom_to_spatial_display_str(spatial_coverages_json)
    spatial_display_strs.length.should eql 1
    spatial_display_strs[0].should eql '-85.0 166.0 -85.0 166.0'
  end

  it 'translates GeoJSON polygon to spatial index str' do
    spatial_coverages_json = [{ 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, 90.0], [180.0, 90.0], [180.0, 30.98], [-180.0, 30.98], [-180.0, 90.0]]] } },
                              { 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, -39.23], [180.0, -39.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -39.23]]] } }]
    spatial_index_strs = @translator.translate_spatial_coverage_geom_to_spatial_index_str(spatial_coverages_json)
    spatial_index_strs.length.should eql 2
    spatial_index_strs[0].should eql '-180.0 30.98 180.0 90.0'
    spatial_index_strs[1].should eql '-180.0 -90.0 180.0 -39.23'
  end

  it 'translates GeoJSON point to spatial index str' do
    spatial_coverages_json = [{ 'geom4326' => { 'type' => 'Point', 'coordinates' => [166.0, -85.0] } }]
    spatial_display_strs = @translator.translate_spatial_coverage_geom_to_spatial_index_str(spatial_coverages_json)
    spatial_display_strs.length.should eql 1
    spatial_display_strs[0].should eql '166.0 -85.0'
  end

  it 'translates GeoJSON geometries to single maximum spatial area value' do
    spatial_coverages_json = [{ 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, 90.0], [180.0, 90.0], [180.0, 32.98], [-180.0, 32.98], [-180.0, 90.0]]] } },
                              { 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]] } },
                              { 'geom4326' => { 'type' => 'Point', 'coordinates' => [166.0, -85.0] } }]
    area = @translator.translate_spatial_coverage_geom_to_spatial_area(spatial_coverages_json)
    area.round(2).should eql 58.77
  end

  it 'translates GeoJSON geometries with global value to single global facet value' do
    spatial_coverages_json = [{ 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, 86.0], [180.0, 86.0], [180.0, -86.0], [-180.0, -86.0], [-180.0, 86.0]]] } },
                              { 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]] } },
                              { 'geom4326' => { 'type' => 'Point', 'coordinates' => [166.0, -85.0] } }]
    global_facet = @translator.translate_spatial_coverage_geom_to_global_facet(spatial_coverages_json)
    global_facet.should eql 'Global'
  end

  it 'translates GeoJSON geometries with no global values to single non-global facet value' do
    spatial_coverages_json = [{ 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]] } },
                              { 'geom4326' => { 'type' => 'Point', 'coordinates' => [166.0, -85.0] } }]
    global_facet = @translator.translate_spatial_coverage_geom_to_global_facet(spatial_coverages_json)
    global_facet.should eql 'Non Global'
  end

  it 'translates GeoJSON without geometries to single no spatial facet value' do
    spatial_coverages_json = []
    global_facet = @translator.translate_spatial_coverage_geom_to_global_facet(spatial_coverages_json)
    global_facet.should eql 'No Spatial Information'
  end

  it 'translates GeoJSON with multiple geometries to multiple scope values' do
    spatial_coverages_json = [{ 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, 86.0], [180.0, 86.0], [180.0, -86.0], [-180.0, -86.0], [-180.0, 86.0]]] } },
                              { 'geom4326' => { 'type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]] } },
                              { 'geom4326' => { 'type' => 'Point', 'coordinates' => [166.0, -85.0] } }]
    scope_facet = @translator.translate_spatial_coverage_geom_to_spatial_scope_facet(spatial_coverages_json)
    scope_facet.length.should eql 3
    scope_facet.should include 'Coverage from over 85 degrees North to -85 degrees South | Global'
    scope_facet.should include 'Less than 1 degree of latitude change | Local'
    scope_facet.should include 'Between 1 and 170 degrees of latitude change | Regional'
  end

  it 'translates GeoJSON with without geometries to nil values' do
    spatial_coverages_json = []
    scope_facet = @translator.translate_spatial_coverage_geom_to_spatial_scope_facet(spatial_coverages_json)
    scope_facet.length.should eql 0
  end

  it 'translates NSIDC platforms json to solr platforms json' do
    platforms_json = [{ 'shortName' => 'AQUA', 'longName' => 'Earth Observing System, AQUA' },
                      { 'shortName' => 'DMSP 5D-2/F11', 'longName' => 'Defense Meteorological Satellite Program-F11' }]

    platforms = @translator.translate_json_string platforms_json

    platforms.should include('AQUA > Earth Observing System, AQUA')
    platforms.should include('DMSP 5D-2/F11 > Defense Meteorological Satellite Program-F11')
  end

  it 'translates NSIDC instruments json to solr instruments json' do
    instruments_json = [{ 'shortName' => 'AMSR-E', 'longName' => 'Advanced Microwave Scanning Radiometer-EOS' },
                        { 'shortName' => 'SSM/I', 'longName' => 'Special Sensor Microwave/Imager' }]

    instruments = @translator.translate_json_string instruments_json

    instruments.should include('AMSR-E > Advanced Microwave Scanning Radiometer-EOS')
    instruments.should include('SSM/I > Special Sensor Microwave/Imager')
  end

  it 'translates NSIDC distribution formats json to solr format facet json' do
    format_json = ['.dat', 'PDF']

    formats = @translator.translate_format_to_facet_format(format_json)

    formats.should include('.dat')
    formats.should include('Documents')
  end

  describe 'temporal resolution faceting' do
    it 'translates NSIDC temporal resolutions to solr facet temporal resolution values' do
      parameters_json = [{ 'name' => 'test1', 'temporalResolution' => { 'type' => 'single', 'resolution' => 'PT3H26M' } },
                         { 'name' => 'test2', 'temporalResolution' => { 'type' => 'range', 'min_resolution' => 'P3D', 'max_resolution' => 'P20D' } }]
      facets = @translator.generate_temporal_resolution_facet_values(parameters_json)
      facets.should eql %w(Subdaily Weekly Submonthly)
    end

    it 'bins second and 59 minute values as Subhourly' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'PT1S').should eql 'Subhourly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'PT59M59S').should eql 'Subhourly'
    end

    it 'bins 1 hour value as Hourly' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'PT60M').should eql 'Hourly'
    end

    it 'bins 1:00:01 and 23:59:59 values as Subdaily' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'PT1H0M1S').should eql 'Subdaily'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'PT23H59M59S').should eql 'Subdaily'
    end

    it 'bins 1 and 2 day as Daily' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P1D').should eql 'Daily'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P2D').should eql 'Daily'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P1DT12H').should eql 'Daily'
    end

    it 'bins 3 and 8 days as Weekly' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P3D').should eql 'Weekly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P8D').should eql 'Weekly'
    end

    it 'bins 9 and 20 days as Submonthly' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P9D').should eql 'Submonthly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P20D').should eql 'Submonthly'
    end

    it 'bins 1 month, 21 days and 31 days as Monthly' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P1M').should eql 'Monthly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P21D').should eql 'Monthly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P31D').should eql 'Monthly'
    end

    it 'bins values less then 1 year as Subyearly' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P364D').should eql 'Subyearly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P11M').should eql 'Subyearly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P3M').should eql 'Subyearly'
    end

    it 'bins 1 year as Yearly' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P1Y').should eql 'Yearly'
    end

    it 'bins values greater then 1 year as Multiyearly' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P2Y').should eql 'Multiyearly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P30Y').should eql 'Multiyearly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P1Y1D').should eql 'Multiyearly'
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => 'P13M').should eql 'Multiyearly'
    end

    it 'bins range as range of facet values' do
      @translator.bin_temporal_resolution_value('type' => 'range', 'min_resolution' => 'PT3H', 'max_resolution' => 'P10D')
        .should eql %w(Subdaily Daily Weekly Submonthly)
    end

    it 'bins varies as varies' do
      @translator.bin_temporal_resolution_value('type' => 'varies').should eql 'Not specified'
    end

    it 'returns not specified if the value is blank' do
      @translator.bin_temporal_resolution_value('type' => 'single', 'resolution' => '').should eql 'Not specified'
      @translator.bin_temporal_resolution_value('type' => 'range', 'min_resolution' => '', 'max_resolution' => '').should eql 'Not specified'
    end
  end
end
