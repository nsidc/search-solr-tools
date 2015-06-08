require 'webmock/rspec'

require 'search_solr_tools/harvesters/nsidc_json'

describe NsidcJsonHarvester do
  bin_configuration = File.read('spec/unit/fixtures/bin_configuration.json')
  before :each do
    stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata//binConfiguration').with(headers: { Accept: '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' }).to_return(status: 200, body: bin_configuration, headers: {})
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

      result = @harvester.docs_with_translated_entries_from_nsidc
      result[:add_docs].first['add']['doc']['authoritative_id'].should eql('G02199')
      result[:add_docs].first['add']['doc']['brokered'].should eql(false)
      result[:add_docs].first['add']['doc']['dataset_version'].should eql(2)
      result[:add_docs].first['add']['doc']['data_centers'].should eql('National Snow and Ice Data Center')
      result[:add_docs].first['add']['doc']['published_date'].should eql('2013-01-01T00:00:00Z')
      result[:add_docs].first['add']['doc']['last_revision_date'].should eql('2013-03-12T21:18:12Z')
      result[:add_docs].first['add']['doc']['facet_format'].should eql([SolrFormat::NOT_SPECIFIED])
    end

    it 'constructs a sucessful doc children hash and an errors hash for failured ids' do
      stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/oai?verb=ListIdentifiers&metadata_prefix=iso')
        .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_oai_identifiers.xml'))

      stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/G02199.json')
        .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
        .to_return(status: 500)

      stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/NSIDC-0419.json')
        .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_G02199.json'), headers: {})

      stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/NSIDC-0582.json')
        .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_G02199.json'), headers: {})

      result = @harvester.docs_with_translated_entries_from_nsidc
      result[:add_docs].first['add']['doc']['authoritative_id'].should eql('G02199')
      result[:add_docs].length.should eql 2
      result[:failure_ids].first.should eql('G02199')
      result[:failure_ids].length.should eql 1
    end
  end
end
