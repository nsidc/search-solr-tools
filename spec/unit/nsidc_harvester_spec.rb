require 'webmock/rspec'
require 'nsidc_harvester'

describe NsidcHarvester do
  before :each do
    @harvester = described_class.new 'integration'
  end

  it 'should retrieve records from the NSIDC OAI url' do
    stub_request(:get, 'http://liquid.colorado.edu:11580/api/dataset/2/oai?metadata_prefix=iso&verb=ListRecords')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: '<gmi:MI_Metadata xmlns:gmi="http://www.isotc211.org/2005/gmi"><foo/></gmi:MI_Metadata>')

    @harvester.results_from_nsidc.first.first_element_child.to_xml.should eql('<foo/>')
  end

  describe 'Adding documents to Solr' do
    it 'constructs an xml document with <doc> children' do
      stub_request(:get, 'http://liquid.colorado.edu:11580/api/dataset/2/oai?metadata_prefix=iso&verb=ListRecords')
        .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_iso.xml'), headers: {})

      @harvester.docs_with_translated_entries_from_nsidc.first.root.first_element_child.name.should eql('doc')
    end

    it 'Issues a request to update Solr with data' do
      stub_request(:post, 'http://liquid.colorado.edu:9283/solr/update?commit=true')
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
