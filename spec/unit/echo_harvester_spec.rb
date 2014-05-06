require 'webmock/rspec'
require 'echo_harvester'

describe EchoHarvester do
  before :each do
    @harvester = described_class.new 'integration'
  end

  it 'should retrieve records from the ECHO CSW url' do
    stub_request(:get, 'https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.echo10?page_num=1&page_size=1000')
      .with(headers: { 'Accept' => '*/*', 'Content-Type' => 'application/echo10+xml', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: '<results><result><Collection></Collection></result></results>')
    @harvester.get_results_from_echo(1).first.first_element_child.to_xml.should eql('<Collection/>')
  end

  describe 'Adding documents to Solr' do
    it 'constructs an xml document with <doc> children' do
      stub_request(:get, 'https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.echo10?page_num=1&page_size=1000')
        .with(headers: { 'Accept' => '*/*', 'Content-Type' => 'application/echo10+xml', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/echo_echo10.xml'), headers: {})

      entries = @harvester.get_results_from_echo(1)
      @harvester.get_docs_with_translated_entries_from_echo(entries).first.root.first_element_child.name.should eql('doc')
    end

    it 'Issues a request to update Solr with data' do
      stub_request(:post, 'http://localhost:9283/solr/update?commit=true')
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
