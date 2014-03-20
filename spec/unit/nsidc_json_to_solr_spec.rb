require 'nsidc_json_to_solr'

describe NsidcJsonToSolr do
  before :each do
    @translator = described_class.new
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
end
