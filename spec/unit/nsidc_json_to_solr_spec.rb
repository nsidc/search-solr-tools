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
end
