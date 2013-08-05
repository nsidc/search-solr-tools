require 'webmock/rspec'
require 'nsidc_harvester'

describe NsidcHarvester do
  before :each do
    @harvester = described_class.new 'integration'
  end

  it 'should retrieve records from the NSIDC OAI url' do
    stub_request(:get, 'http://liquid.colorado.edu:11680/metadata-interface/oai/provider?verb=ListRecords&metadataPrefix=iso')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: '<gmi:MI_Metadata xmlns:gmi="http://eden.ign.fr/xsd/isotc211/isofull/20090316/gmi/"><foo/></gmi:MI_Metadata>')

    @harvester.get_results_from_nsidc.first.first_element_child.to_xml.should eql('<foo/>')
  end

  describe 'Adding documents to Solr' do
    it 'constructs an xml document with <doc> children' do
      stub_request(:get, 'http://liquid.colorado.edu:11680/metadata-interface/oai/provider?verb=ListRecords&metadataPrefix=iso')
        .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/fixtures/nsidc_iso.xml'), headers: {})

      @harvester.get_docs_with_translated_entries_from_nsidc.first.root.first_element_child.name.should eql('doc')
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
