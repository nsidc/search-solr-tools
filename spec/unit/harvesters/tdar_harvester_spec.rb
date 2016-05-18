require 'spec_helper'

describe SearchSolrTools::Harvesters::Tdar do
  before :each do
    @harvester = described_class.new 'integration'
  end

  it 'should retrieve records from the TDAR url' do
    request_url = 'http://core.tdar.org/search/rss?_tDAR.searchType=ACADIS_RSS&geoMode=ENVELOPE&groups[0][.latitudeLongitudeBoxes][0][.maximumLatitude]=90&groups[0][.latitudeLongitudeBoxes][0][.maximumLongitude]=180&groups[0][.latitudeLongitudeBoxes][0][.minimumLatitude]=45&groups[0][.latitudeLongitudeBoxes][0][.minimumLongitude]=-180&recordsPerPage=100&resourceTypes=DATASET&startRecord=1'
    stub_request(:get, request_url)
      .with(headers: { 'Accept' => '*/*', 'Content-Type' => 'application/xml', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: '<feed xmlns="http://www.w3.org/2005/Atom"><entry><foo/></entry></feed>')
    expect(@harvester.get_results_from_tdar(1).first.first_element_child.to_xml).to eql('<foo/>')
  end

  describe 'Adding documents to Solr' do
    it 'constructs an xml document with <doc> children' do
      request_url = 'http://core.tdar.org/search/rss?_tDAR.searchType=ACADIS_RSS&geoMode=ENVELOPE&groups[0][.latitudeLongitudeBoxes][0][.maximumLatitude]=90&groups[0][.latitudeLongitudeBoxes][0][.maximumLongitude]=180&groups[0][.latitudeLongitudeBoxes][0][.minimumLatitude]=45&groups[0][.latitudeLongitudeBoxes][0][.minimumLongitude]=-180&recordsPerPage=100&resourceTypes=DATASET&startRecord=1'
      stub_request(:get, request_url)
        .with(headers: { 'Accept' => '*/*', 'Content-Type' => 'application/xml', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/tdar_opensearch.xml'), headers: {})

      entries = @harvester.get_results_from_tdar(1)
      expect(@harvester.get_docs_with_translated_entries_from_tdar(entries).first.root.first_element_child.name).to eql('doc')
    end

    it 'Issues a request to update Solr with data' do
      stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?commit=true')
        .with(body: Nokogiri.XML('<add><foo></add>').to_xml,
              headers: { 'Accept'          => '*/*; q=0.5, application/xml',
                         'Accept-Encoding' => 'gzip, deflate',
                         'Content-Length'  => '44',
                         'Content-Type'    => 'text/xml; charset=utf-8',
                         'User-Agent'      => 'Ruby' })
        .to_return(status: 200, body: 'success', headers: {})

      expect(@harvester.insert_solr_doc(Nokogiri.XML('<add><foo></add>'))).to eql(true)
    end
  end
end
