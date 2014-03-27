require 'webmock/rspec'
require 'nsidc_json_harvester'

describe NsidcJsonHarvester do
  before :each do
    @harvester = described_class.new 'integration'
  end

  it 'should retrieve dataset identifiers from the NSIDC OAI url' do
    stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/oai?verb=ListIdentifiers&metadata_prefix=iso')
    .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
    .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_oai_identifiers.xml'))

    @harvester.result_ids_from_nsidc.first.text.should eql('oai:nsidc/G02199')
  end

  describe 'Adding documents to Solr' do
    it 'constructs a hash with doc children' do
      stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/oai?verb=ListIdentifiers&metadata_prefix=iso')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_oai_identifiers.xml'))

      stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/G02199.json')
      .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_G02199.json'), headers: {})

      stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/NSIDC-0419.json')
      .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_G02199.json'), headers: {})

      stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/NSIDC-0582.json')
      .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_G02199.json'), headers: {})

      @harvester.docs_with_translated_entries_from_nsidc.first['add']['doc']['authoritative_id'].should eql('G02199')
      @harvester.docs_with_translated_entries_from_nsidc.first['add']['doc']['brokered'].should eql(false)
      @harvester.docs_with_translated_entries_from_nsidc.first['add']['doc']['dataset_version'].should eql(2)
      @harvester.docs_with_translated_entries_from_nsidc.first['add']['doc']['data_centers'].should eql('National Snow and Ice Data Center')
      @harvester.docs_with_translated_entries_from_nsidc.first['add']['doc']['published_date'].should eql('2013-01-01T00:00:00Z')
      @harvester.docs_with_translated_entries_from_nsidc.first['add']['doc']['last_revision_date'].should eql('2013-03-12T21:18:12Z')
      @harvester.docs_with_translated_entries_from_nsidc.first['add']['doc']['facet_format'].should eql(['PDF', 'Microsoft Excel'])
    end
  end
end
