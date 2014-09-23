require 'webmock/rspec'
require 'bcodmo_harvester'

describe BcoDmoHarvester do
  before :all do
    @harvester = described_class.new 'integration'
  end

  describe 'Adding documents to Solr' do
    before :all do
      stub_request(:get, 'http://www.bco-dmo.org/nsidc/arctic-deployments.json')
      .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/bcdmo.json'))
      stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/datasets')
      .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/bcodmo_datasets.json'))
      stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/geometry')
      .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.open('spec/unit/fixtures/bcodmo_geometry.json'))
      @result = @harvester.translate_bcodmo
    end

    it 'successfully creates a solr addition (ingest) hash' do
      @result[:add_docs].length.should eql 3
      first_result = @result[:add_docs].first['add']['doc']
      first_result['title'].should eql('Mussel growth rates')
      first_result['authoritative_id'].should eql('511644511584')
      first_result['data_centers'].should eql('Biological and Chemical Oceanography Data Management Office')
      first_result['facet_data_center'].should eql('Biological and Chemical Oceanography Data Management Office | BCO-DMO')
      first_result['summary'].should eql('Mussels were transplanted from a single location on Tatoosh Island to other areas on Tatoosh Island and to the other sites. Mussels were held in mesh (vexar) packages which were bolted to the rock. Mussels were marked via engraving numbers on their shells with a dremel tool, and measured with calipers.  Data have been analyzed and is of high quality, measurement error is less than 1 mm. Mussels were measured in centimeters. ')
      first_result['temporal_coverages'][0].should eql('2008-07-02,2010-08-22')
      first_result['temporal'][0].should eql('20.080702 20.100822')
      first_result['facet_temporal_duration'][0].should eql('1+ years')
      first_result['dataset_version'].should eql '20140414'
      first_result['temporal'][0].should eql '20.080702 20.100822'
      first_result['last_revision_date'].should eql '2014-04-14T00:00:00Z'
      first_result['dataset_url'].should eql 'http://data.bco-dmo.org/jg/serv/BCO/Nitrogen_Regen/mussel_growth.html0%7Bdir=data.bco-dmo.org/jg/dir/BCO/Nitrogen_Regen/,info=data.bco-dmo.org/jg/info/BCO/Nitrogen_Regen/mussel_growth%7D'
      first_result['source'].should eql 'ADE'
      first_result['facet_spatial_scope'][0].should eql 'Less than 1 degree of latitude change | Local'
      first_result['spatial_area'].should eql 0.26889999999999503
      first_result['spatial'].should eql ['-122.6446 48.4057', '-122.7774 48.1441', '-122.6621 48.413', '-123.6363 48.1509', '-124.7382 48.3911', '-124.7246 48.3869']
      first_result['spatial'].length.should eql 6
    end

    it 'successfully handles a black dataset version' do
      @result[:add_docs][2]['add']['doc']['version'].should be_nil
    end

    it 'successfully handles a blank deployment version date' do
      @result[:add_docs][2]['add']['doc']['last_revision_date'].should be_nil
    end

    it 'successfully handles a blank dataset description' do
      @result[:add_docs][2]['add']['doc']['summary'].should eql 'Temperature and light time series in the Strait of Juan de Fuca, fall 2009 '
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
