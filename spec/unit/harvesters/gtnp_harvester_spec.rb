require 'spec_helper'

describe SearchSolrTools::Harvesters::GtnP do
  gtnp_borehole_json = File.read('spec/unit/fixtures/gtnp_boreholes.json')
  gtnp_activelayers_json = File.read('spec/unit/fixtures/gtnp_activelayers.json')

  title_ids = ['Global Terrestrial Network - Thermal State of Permafrost - Keller 4. King George Island',
               'Global Terrestrial Network - Thermal State of Permafrost - Barrow 1 (N.Meadow Lake 1 NM1)',
               'Global Terrestrial Network - Active Layer Thawing - Happy Valley 1km',
               'Global Terrestrial Network - Active Layer Thawing - Betty Pingo',
               'Global Terrestrial Network - Active Layer Thawing - Deadhorse',
               'Global Terrestrial Network - Active Layer Thawing - Talnik']
  data_center = 'Global Terrestrial Network for Permafrost'
  facet_data_center = "#{data_center} | GTN-P"
  summary = ['The Global Terrestrial Network for Permafrost Data Management System contains time series for borehole temperatures (TSP: Thermal State of Permafrost) plus air and surface temperature and soil moisture (DUE Permafrost, MODIS) measured in the terrestrial Panarctic, Antarctic and Mountainous realms.',
             'The Global Terrestrial Network for Permafrost Data Management System contains time series for active layer thawing measurements(ALT: Active Layer Thawing) plus air and surface temperature and soil moisture (DUE Permafrost, MODIS) measured in the terrestrial Panarctic, Antarctic and Mountainous realms.']
  urls = ['http://gtnpdatabase.org/boreholes/view/646',
          'http://gtnpdatabase.org/boreholes/view/27',
          'http://gtnpdatabase.org/activelayers/view/1',
          'http://gtnpdatabase.org/activelayers/view/6',
          'http://gtnpdatabase.org/activelayers/view/14',
          'http://gtnpdatabase.org/activelayers/view/26']
  source = 'ADE'
  facet_spatial_scope = ['Less than 1 degree of latitude change | Local']
  spatial_coverages = [['-62.075753 -58.403733 -62.075753 -58.403733'],
                       ['71.310532 -156.654053 71.310532 -156.654053'],
                       ['69.100007 -148.498186 69.100007 -148.498186'],
                       ['70.284779 -148.866914 70.284779 -148.866914'],
                       ['70.166667 -148.466667 70.166667 -148.466667'],
                       ['67.33 63.733 67.33 63.733']]
  spatial_area = 0.0
  spatial = [['-58.403733 -62.075753'],
             ['-156.654053 71.310532'],
             ['-148.498186 69.100007'],
             ['-148.866914 70.284779'],
             ['-148.466667 70.166667'],
             ['63.733 67.33']]
  temporal_coverages = 'Not specified'
  authors = [['Carlos Schaefer'],
             ['Vladimir E. Romanovsky', 'Alexander L. Kholodov', 'Thomas E. Osterkamp', 'Kenji Yoshikawa', 'William L. Cable'],
             ['Nikolay Shiklomanov'],
             ['Vladimir E. Romanovsky', 'Alexander L. Kholodov', 'William L. Cable'],
             []]

  before :each do
    @harvester = described_class.new
  end

  describe 'Parsing records' do
    it 'reports IDs of unsuccessfully parsed records' do
      result = @harvester.parse_record([{ 'title': 'Failed ID' }, {}])
      expect(result[:failure_ids].length).to be 1
      expect(result[:failure_ids][0]).to eql 'Failed ID'
    end
  end

  describe 'Successfully adding documents to Solr' do
    before :each do
      stub_request(:get, 'http://www.gtnpdatabase.org/rest/boreholes/json')
        .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: gtnp_borehole_json, headers: {})

      stub_request(:get, 'http://www.gtnpdatabase.org/rest/activelayers/json')
        .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: gtnp_activelayers_json, headers: {})

      @result = @harvester.translate_gtnp
    end

    it 'translates expected number of GTN-P JSON records into SOLR docs' do
      expect(@result[:add_docs].length).to eql 6
    end

    it 'produces a SOLR ingest hash for each valid GTN-P record' do
      @result[:add_docs].each do |rec|
        doc = rec['add']['doc']
        expect(title_ids).to include(doc['title'])
        expect(title_ids).to include(doc['authoritative_id'])
        expect(doc['data_centers']).to eql data_center
        expect(doc['facet_data_center']).to eql facet_data_center
        expect(summary).to include(doc['summary'])
        expect(urls).to include(doc['dataset_url'])
        expect(doc['source']).to eql source
        expect(doc['facet_spatial_scope']).to eql facet_spatial_scope
        expect(spatial_coverages).to include(doc['spatial_coverages'])
        expect(doc['spatial_area']).to eql spatial_area
        expect(spatial).to include(doc['spatial'])
        expect(doc['temporal_coverages']).to eql temporal_coverages
        expect(authors).to include(doc['authors'])
      end
    end
  end

  describe 'Unsuccessfully adding documents to Solr' do
    before :each do
      stub_request(:get, 'http://www.gtnpdatabase.org/rest/boreholes/json')
        .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: '[{"title": "Failed ID"}, {}]', headers: {})

      stub_request(:get, 'http://www.gtnpdatabase.org/rest/activelayers/json')
        .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: gtnp_activelayers_json, headers: {})

      @result = @harvester.translate_gtnp
    end

    it 'translates expected number of GTN-P JSON records into SOLR docs' do
      expect(@result[:failure_ids].length).to eql 1
      expect(@result[:add_docs].length).to eql 4
    end
  end
end
