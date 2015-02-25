require 'webmock/rspec'
require 'tdar_harvester'

describe TdarHarvester do
  before :each do
    @harvester = described_class.new 'integration'
  end

  it 'should retrieve records from the TDAR url' do
    stub_request(:get, 'http://core.tdar.org/search/rss?resourceTypes=DATASET&recordsPerPage=100&startRecord=1')
      .with(headers: { 'Accept' => '*/*', 'Content-Type' => 'application/xml', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: '<feed xmlns="http://www.w3.org/2005/Atom"><entry><foo/></entry></feed>')
    @harvester.get_results_from_tdar(1).first.first_element_child.to_xml.should eql('<foo/>')
  end

  describe 'Adding documents to Solr' do
    it 'constructs an xml document with <doc> children' do
      stub_request(:get, 'http://core.tdar.org/search/rss?resourceTypes=DATASET&recordsPerPage=100&startRecord=1')
        .with(headers: { 'Accept' => '*/*', 'Content-Type' => 'application/xml', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/tdar_opensearch.xml'), headers: {})

      entries = @harvester.get_results_from_tdar(1)
      @harvester.get_docs_with_translated_entries_from_tdar(entries).first.root.first_element_child.name.should eql('doc')
    end

    it 'Issues a request to update Solr with data' do
      stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?commit=true')
        .with(body: Nokogiri.XML('<add><foo></add>').to_xml,
              headers: {
                'Accept' => '*/*; q=0.5, application/xml',
                'Accept-Encoding' => 'gzip, deflate',
                'Content-Length' => '44',
                'Content-Type' => 'text/xml; charset=utf-8',
                'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: 'success', headers: {})

      @harvester.insert_solr_doc(Nokogiri.XML('<add><foo></add>')).should eql(true)
    end
  end
end