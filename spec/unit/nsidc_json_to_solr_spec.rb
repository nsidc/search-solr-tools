require 'selectors/nsidc_json_to_solr'

describe NsidcJsonToSolr do
  before :each do
    @translator = described_class.new
  end

  it 'translates NSIDC JSON date to SOLR format iso8601 date' do
    date = '2013-03-12T21:18:12-06:00'
    (SolrFormat.date_str date).should eql '2013-03-12T21:18:12Z'
  end

  it 'translates NSIDC internal data center to facet_sponsored_program string' do
    internal_datacenters_json = [{ 'shortName' => 'NASA DAAC', 'longName' => 'NASA DAAC at the National Snow and Ice Data Center', 'url' => 'http://nsidc.org/daac/index.html' },
                                 { 'shortName' => 'NOAA @ NSIDC', 'longName' => 'NSIDC National Oceanic and Atmospheric Administration', 'url' => 'http://nsidc.org/noaa/' }]
    facet_values = @translator.translate_short_long_names_to_facet_value(internal_datacenters_json)
    facet_values[0].should eql 'NASA DAAC at the National Snow and Ice Data Center | NASA DAAC'
    facet_values[1].should eql 'NSIDC National Oceanic and Atmospheric Administration | NOAA @ NSIDC'
  end

  it 'translates NSIDC sensors to facet_sensor string' do
    internal_datacenters_json = [{ 'shortName' => 'SMMR', 'longName' => 'Scanning Multichannel Microwave Radiometer' },
                                 { 'shortName' => 'MISC', 'longName' => '' },
                                 { 'shortName' => 'missing', 'longName' => nil }]
    facet_values = @translator.translate_short_long_names_to_facet_value(internal_datacenters_json)
    facet_values[0].should eql 'Scanning Multichannel Microwave Radiometer | SMMR'
    facet_values[1].should eql ' | MISC'
    facet_values[2].should eql ' | missing'
  end

  it 'translates NSIDC citation creators to authors list' do
    creator_json = { 'creators' => [
      { 'role' => 'author', 'firstName' => 'NSIDC',  'middleName' => '',   'lastName' => 'User Services' },
      { 'role' => 'editor', 'firstName' => 'Claire', 'middleName' => 'L.', 'lastName' => 'Parkinson' },
      { 'role' => 'author', 'firstName' => 'Per',    'middleName' => '',   'lastName' => 'Gloersen' },
      { 'role' => '',       'firstName' => 'H. Jay', 'middleName' => '',   'lastName' => 'Zwally' }] }
    authors = @translator.translate_personnel_and_creators_to_authors(nil, @translator.generate_data_citation_creators(creator_json))
    authors[0].should eql('Claire L. Parkinson')
    authors[1].should eql('Per Gloersen')
    authors[2].should eql('H. Jay Zwally')
  end

  it 'translates NSIDC personnel json to authors list' do
    personnel_json = [{ 'role' => 'technical contact', 'firstName' => 'NSIDC', 'middleName' => '', 'lastName' => 'User Services' },
                      { 'role' => 'investigator', 'firstName' => 'Claire', 'middleName' => 'L.', 'lastName' => 'Parkinson' },
                      { 'role' => 'investigator', 'firstName' => 'Per', 'middleName' => '', 'lastName' => 'Gloersen' },
                      { 'role' => 'investigator', 'firstName' => 'H. Jay', 'middleName' => '', 'lastName' => 'Zwally' }]

    authors = @translator.translate_personnel_and_creators_to_authors(personnel_json, @translator.generate_data_citation_creators(nil))
    authors[0].should_not include('NSIDC User Services')
    authors[0].should eql('Claire L. Parkinson')
    authors[1].should eql('Per Gloersen')
    authors[2].should eql('H. Jay Zwally')
  end

  it 'translates NSIDC citation creators and personnel json to authors list without duplicates' do
    personnel_json = [{ 'role' => 'technical contact', 'firstName' => 'NSIDC', 'middleName' => '', 'lastName' => 'User Services' },
                      { 'role' => 'investigator', 'firstName' => 'Claire', 'middleName' => 'L.', 'lastName' => 'Parkinson' },
                      { 'role' => 'investigator', 'firstName' => 'Per', 'middleName' => '', 'lastName' => 'Gloersen' },
                      { 'role' => 'investigator', 'firstName' => 'H. Jay', 'middleName' => '', 'lastName' => 'Zwally' }]

    creator_json = { 'creators' => [
      { 'role' => 'author', 'firstName' => 'NSIDC',  'middleName' => '',   'lastName' => 'User Services' },
      { 'role' => 'editor', 'firstName' => 'Claire', 'middleName' => 'L.', 'lastName' => 'Parkinson' },
      { 'role' => 'author', 'firstName' => 'Per',    'middleName' => '',   'lastName' => 'Gloersen' },
      { 'role' => 'author', 'firstName' => 'H. Jay', 'middleName' => '',   'lastName' => 'Zwally' },
      { 'role' => 'author', 'firstName' => 'Ian',    'middleName' => 'M',  'lastName' => 'Banks' }] }

    authors = @translator.translate_personnel_and_creators_to_authors(personnel_json, @translator.generate_data_citation_creators(creator_json))
    authors.length.should eql 4
    authors[0].should eql('Claire L. Parkinson')
    authors[1].should eql('Per Gloersen')
    authors[2].should eql('H. Jay Zwally')
    authors[3].should eql('Ian M Banks')
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

    params = @translator.translate_json_string(parameters_json, NsidcJsonToSolr::PARAMETER_PARTS)
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

    params = @translator.translate_json_string(parameters_json, NsidcJsonToSolr::PARAMETER_PARTS)
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

    params = @translator.translate_json_string(parameters_json, NsidcJsonToSolr::PARAMETER_PARTS)
    params.should include('EARTH SCIENCE > Cryosphere > Sea Ice > Ice Extent')
    params.should include('EARTH SCIENCE > Terrestrial Hydrosphere > Snow/Ice > Ice Extent')
    params.should include('EARTH SCIENCE > Oceans > Sea Ice > Ice Extent')
    params.should include('EARTH SCIENCE > Cryosphere > Sea Ice > Sea Ice Concentration')
    params.should include('EARTH SCIENCE > Oceans > Sea Ice > Sea Ice Concentration')
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
      facets = @translator.translate_temporal_resolution_facet_values(parameters_json)
      facets.should eql %w(Subdaily Weekly Submonthly)
    end
  end

  describe 'spatial resolution faceting' do
    it 'translates NSIDC spatial resolutions to solr facet spatial resolution values' do
      parameters_json = [{ 'name' => 'test1',
                           'spatialXResolution' => { 'type' => 'single', 'resolution' => '5000 m' },
                           'spatialYResolution' => { 'type' => 'single', 'resolution' => '100000 m' } },
                         { 'name' => 'test2',
                           'spatialXResolution' => { 'type' => 'range', 'min_resolution' => '300 m', 'max_resolution' => '2200 m' },
                           'spatialYResolution' => { 'type' => 'range', 'min_resolution' => '300 m', 'max_resolution' => '2200 m' } }]
      facets = @translator.translate_spatial_resolution_facet_values(parameters_json)
      facets.sort.should eql ['0 - 500 m', '501 m - 1 km', '2 - 5 km', '>30 km'].sort
    end
  end

  describe 'sensor faceting' do
    it 'translates NSIDC instruments to defined solr facet sensor value' do
      sensor_json = [{ 'shortName' => 'MODIS', 'longName' => 'Modis Test Instrument' }, { 'shortName' => 'TEST', 'longName' => 'Instrument Long Name' }]
      facets = @translator.translate_sensor_to_facet_sensor(sensor_json)
      facets.sort.should eql [' | TESTBIN', 'Modis Test Instrument | MODIS']
    end
  end
end
