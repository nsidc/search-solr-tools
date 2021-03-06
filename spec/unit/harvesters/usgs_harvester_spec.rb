require 'spec_helper'

describe SearchSolrTools::Harvesters::Usgs, :skip => "Obsolete harvester, would need to be updated to new status handling method" do
  before :each do
    @harvester = described_class.new 'integration'
  end

  it 'should retrieve records from the USGS CSW url' do
    stub_request(:get, 'https://www.sciencebase.gov/catalog/item/527cf4ede4b0850ea05182ee/csw?ElementSetName=full&TypeNames=&constraint=%3CFilter%20xmlns:ogc=%22http://www.opengis.net/ogc%22%20xmlns:gml=%22http://www.opengis.net/gml%22%20xmlns:apiso=%22http://www.opengis.net/cat/csw/apiso/1.0%22%3E%3Cogc:BBOX%3E%3CPropertyName%3Eapiso:BoundingBox%3C/PropertyName%3E%3Cgml:Envelope%3E%3Cgml:lowerCorner%3E-180%2045%3C/gml:lowerCorner%3E%3Cgml:upperCorner%3E180%2090%3C/gml:upperCorner%3E%3C/gml:Envelope%3E%3C/ogc:BBOX%3E%3C/Filter%3E&maxRecords=100&outputFormat=application/xml&outputSchema=http://www.isotc211.org/2005/gmd&request=GetRecords&resultType=results&service=CSW&startPosition=1&version=2.0.2')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: '<gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd"><foo/></gmd:MD_Metadata>')
    expect(@harvester.get_results_from_usgs(1).first.first_element_child.to_xml).to eql('<foo/>')
  end

  describe 'Adding documents to Solr' do
    it 'constructs an xml document with <doc> children' do
      stub_request(:get, 'https://www.sciencebase.gov/catalog/item/527cf4ede4b0850ea05182ee/csw?ElementSetName=full&TypeNames=&constraint=%3CFilter%20xmlns:ogc=%22http://www.opengis.net/ogc%22%20xmlns:gml=%22http://www.opengis.net/gml%22%20xmlns:apiso=%22http://www.opengis.net/cat/csw/apiso/1.0%22%3E%3Cogc:BBOX%3E%3CPropertyName%3Eapiso:BoundingBox%3C/PropertyName%3E%3Cgml:Envelope%3E%3Cgml:lowerCorner%3E-180%2045%3C/gml:lowerCorner%3E%3Cgml:upperCorner%3E180%2090%3C/gml:upperCorner%3E%3C/gml:Envelope%3E%3C/ogc:BBOX%3E%3C/Filter%3E&maxRecords=100&outputFormat=application/xml&outputSchema=http://www.isotc211.org/2005/gmd&request=GetRecords&resultType=results&service=CSW&startPosition=1&version=2.0.2')
        .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/usgs_iso.xml'), headers: {})

      entries = @harvester.get_results_from_usgs(1)
      expect(@harvester.get_docs_with_translated_entries_from_usgs(entries).first.root.first_element_child.name).to eql('doc')
    end

    it 'Issues a request to update Solr with data' do
      stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?commit=true')
        .with(body: Nokogiri.XML('<add><foo></add>').to_xml,
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => GZIP_DEFLATE_IDENTITY,
                         'Content-Length' => '44',
                         'Content-Type' => 'text/xml; charset=utf-8' })
        .to_return(status: 200, body: 'success', headers: {})

      expect(@harvester.insert_solr_doc(Nokogiri.XML('<add><foo></add>'))).to eql(true)
    end
  end
end
