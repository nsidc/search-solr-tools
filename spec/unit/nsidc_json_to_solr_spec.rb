require 'nsidc_json_to_solr'

describe NsidcJsonToSolr do
  before :each do
    @translator = described_class.new
  end

  it 'translates NSIDC JSON date to SOLR format iso8601 date' do
    date = '2013-03-12T21:18:12-06:00'
    (IsoToSolrFormat::STRING_DATE.call date).should eql '2013-03-12T21:18:12Z'
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
    parameters_json = [{ 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => 'test detail' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' }]

    params = @translator.translate_parameters parameters_json
    params.should include('EARTH SCIENCE')
    params.should include('Oceans')
    params.should include('Sea Ice')
    params.should include('Sea Ice Concentration')
    params.should include('test detail')
    params.should_not include('')
  end

  it 'translates NSIDC parameters json to parameter strings' do
    parameters_json = [{ 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => 'test detail' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Cryosphere', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' },
                       { 'category' => 'EARTH SCIENCE', 'topic' => 'Oceans', 'term' => 'Sea Ice', 'variableLevel1' => 'Sea Ice Concentration', 'variableLevel2' => '', 'variableLevel3' => '', 'detailedVariable' => '' }]

    params = @translator.translate_parameters_to_string parameters_json
    params.should include('EARTH SCIENCE > Cryosphere > Sea Ice > Sea Ice Concentration > test detail')
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
end
