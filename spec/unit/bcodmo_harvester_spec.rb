require 'webmock/rspec'
require 'bcodmo_harvester'

describe BcoDmoHarvester do
  before :each do
    @harvester = described_class.new 'integration'
  end

  describe 'Adding documents to Solr' do
    it 'successfully creates a solr addition (ingest) hash' do
      stub_request(:get, 'http://www.bco-dmo.org/nsidc/arctic-deployments.json')
      .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/bcdmo.json'))
      stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/datasets')
      .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/bcodmo_datasets.json'))
      stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/geometry')
      .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/bcodmo_geometry.json'))
      result = @harvester.translate_bcodmo
      result[:add_docs].size.should eql(3)
      first_result = result[:add_docs].first['add']['doc']
      first_result['title'].should eql('Mussel growth rates')
      first_result['authoritative_id'].should eql('511644511584')
      first_result['data_centers'].should eql('Biological and Chemical Oceanography Data Management Office')
      first_result['facet_data_center'].should eql('Biological and Chemical Oceanography Data Management Office | BCO-DMO')
      first_result['summary'].should eql('Mussels were transplanted from a single location on Tatoosh Island to other areas on Tatoosh Island and to the other sites. Mussels were held in mesh (vexar) packages which were bolted to the rock. Mussels were marked via engraving numbers on their shells with a dremel tool, and measured with calipers.  Data have been analyzed and is of high quality, measurement error is less than 1 mm. Mussels were measured in centimeters. ')
      first_result['temporal_coverages'][0].should eql('2008-07-02,2010-08-22')
      first_result['temporal'][0].should eql('20.080702 20.100822')
      first_result['facet_temporal_duration'][0].should eql('1+ years')
    end
  end
  it 'successfully handles failed dataset returns' do
    stub_request(:get, 'http://www.bco-dmo.org/nsidc/arctic-deployments.json')
    .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
    .to_return(status: 200, body: File.open('spec/unit/fixtures/bcdmo.json'))
    stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/datasets')
    .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
    .to_return(status: 500, body: File.open('spec/unit/fixtures/bcodmo_datasets.json', headers: {}))
    stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/geometry')
    .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
    .to_return(status: 200, body: File.open('spec/unit/fixtures/bcodmo_geometry.json'))
    result = @harvester.translate_bcodmo
    result[:failure_ids].size.should eql(1)
    result[:failure_ids][0].should eql('511644')
  end
end
