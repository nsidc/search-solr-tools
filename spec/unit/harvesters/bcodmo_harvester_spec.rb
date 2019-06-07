require 'spec_helper'

stubbed_headers = {
  'Accept' => '*/*',
  'Accept-Encoding' => 'gzip, deflate',
  'Host' => 'www.bco-dmo.org',
}

describe SearchSolrTools::Harvesters::BcoDmo do
  before :all do
    @harvester = described_class.new 'integration'
  end

  describe 'Adding documents to Solr' do
    before :all do
      stub_request(:get, 'http://www.bco-dmo.org/nsidc/arctic-deployments.json')
        .with(headers: stubbed_headers)
        .to_return(status: 200, body: File.read('spec/unit/fixtures/bcdmo.json'), headers: {})
      stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/datasets')
        .to_return(status: 200, body: File.read('spec/unit/fixtures/bcodmo_datasets.json'), headers: {})
      stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/geometry')
        .with(headers: stubbed_headers)
        .to_return(status: 200, body: File.read('spec/unit/fixtures/bcodmo_geometry.json'), headers: {})

      stub_request(:get, 'http://www.bco-dmo.org/api/dataset/511584/originators')
        .to_return(status: 200, body: File.read('spec/unit/fixtures/bcodmo_originators_511584.json'))

      stub_request(:get, 'http://www.bco-dmo.org/api/dataset/514182/originators')
        .to_return(status: 200, body: File.read('spec/unit/fixtures/bcodmo_originators_514182.json'))

      @result = @harvester.translate_bcodmo
    end

    it 'successfully creates a solr addition (ingest) hash' do
      expect(@result[:add_docs].length).to eql 3
      first_result = @result[:add_docs].first['add']['doc']
      expect(first_result['title']).to eql('Mussel growth rates')
      expect(first_result['authoritative_id']).to eql('511644511584')
      expect(first_result['data_centers']).to eql('Biological and Chemical Oceanography Data Management Office')
      expect(first_result['facet_data_center']).to eql('Biological and Chemical Oceanography Data Management Office | BCO-DMO')
      expect(first_result['summary']).to eql('Mussels were transplanted from a single location on Tatoosh Island to other areas on Tatoosh Island and to the other sites. Mussels were held in mesh (vexar) packages which were bolted to the rock. Mussels were marked via engraving numbers on their shells with a dremel tool, and measured with calipers.  Data have been analyzed and is of high quality, measurement error is less than 1 mm. Mussels were measured in centimeters. ')
      expect(first_result['temporal_coverages'][0]).to eql('2008-07-02,2010-08-22')
      expect(first_result['temporal'][0]).to eql('20.080702 20.100822')
      expect(first_result['facet_temporal_duration'][0]).to eql('1+ years')
      expect(first_result['dataset_version']).to eql '20140414'
      expect(first_result['temporal'][0]).to eql '20.080702 20.100822'
      expect(first_result['last_revision_date']).to eql '2014-04-14T00:00:00Z'
      expect(first_result['dataset_url']).to eql 'http://data.bco-dmo.org/jg/serv/BCO/Nitrogen_Regen/mussel_growth.html0%7Bdir=data.bco-dmo.org/jg/dir/BCO/Nitrogen_Regen/,info=data.bco-dmo.org/jg/info/BCO/Nitrogen_Regen/mussel_growth%7D'
      expect(first_result['source']).to eql 'ADE'
      expect(first_result['facet_spatial_scope'][0]).to eql 'Less than 1 degree of latitude change | Local'
      expect(first_result['spatial_area']).to eql 0.26889999999999503
      expect(first_result['spatial']).to eql ['-122.6446 48.4057', '-122.7774 48.1441', '-122.6621 48.413', '-123.6363 48.1509', '-124.7382 48.3911', '-124.7246 48.3869']
      expect(first_result['spatial'].length).to eql 6
    end

    it 'successfully handles a blank dataset version' do
      expect(@result[:add_docs][2]['add']['doc']['version']).to be_nil
    end

    it 'successfully handles a blank deployment version date' do
      expect(@result[:add_docs][2]['add']['doc']['last_revision_date']).to be_nil
    end

    it 'successfully handles a blank dataset description' do
      expect(@result[:add_docs][2]['add']['doc']['summary']).to eql 'Temperature and light time series in the Strait of Juan de Fuca, fall 2009 '
    end
  end

  it 'successfully handles failed dataset returns' do
    stub_request(:get, 'http://www.bco-dmo.org/nsidc/arctic-deployments.json')
      .with(headers: stubbed_headers)
      .to_return(status: 200, body: File.open('spec/unit/fixtures/bcdmo.json'), headers: {})
    stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/datasets')
      .with(headers: stubbed_headers)
      .to_return(status: 500, body: File.open('spec/unit/fixtures/bcodmo_datasets.json', headers: {}))
    stub_request(:get, 'http://www.bco-dmo.org/api/deployment/511644/geometry')
      .with(headers: stubbed_headers)
      .to_return(status: 200, body: File.open('spec/unit/fixtures/bcodmo_geometry.json'))
    result = @harvester.translate_bcodmo
    expect(result[:failure_ids].size).to eql(1)
    expect(result[:failure_ids][0]).to eql('511644')
  end
end
