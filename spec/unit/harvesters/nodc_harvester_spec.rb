require 'spec_helper'

describe SearchSolrTools::Harvesters::Nodc do
  before :each do
    @harvester = described_class.new 'integration'
  end

  it 'should retrieve records from the NODC CSW url' do
    stub_request(:get, 'https://data.nodc.noaa.gov/geoportal/csw?ElementSetName=full&TypeNames=gmd:MD_Metadata&constraint=%3CFilter%20xmlns:ogc=%22http://www.opengis.net/ogc%22%20xmlns:gml=%22http://www.opengis.net/gml%22%20xmlns:apiso=%22http://www.opengis.net/cat/csw/apiso/1.0%22%3E%3Cogc:BBOX%3E%3CPropertyName%3Eapiso:BoundingBox%3C/PropertyName%3E%3Cgml:Envelope%3E%3Cgml:lowerCorner%3E-180%2045%3C/gml:lowerCorner%3E%3Cgml:upperCorner%3E180%2090%3C/gml:upperCorner%3E%3C/gml:Envelope%3E%3C/ogc:BBOX%3E%3C/Filter%3E&maxRecords=50&outputFormat=application/xml&outputSchema=http://www.isotc211.org/2005/gmd&request=GetRecords&resultType=results&service=CSW&startPosition=1&version=2.0.2')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: '<gmi:MI_Metadata xmlns:gmi="http://www.isotc211.org/2005/gmi"><foo/></gmi:MI_Metadata>')
    expect(@harvester.get_results_from_nodc(1).first.first_element_child.to_xml).to eql('<foo/>')
  end

  describe 'Adding documents to Solr' do
    it 'constructs an xml document with <doc> children' do
      stub_request(:get, 'https://data.nodc.noaa.gov/geoportal/csw?ElementSetName=full&TypeNames=gmd:MD_Metadata&constraint=%3CFilter%20xmlns:ogc=%22http://www.opengis.net/ogc%22%20xmlns:gml=%22http://www.opengis.net/gml%22%20xmlns:apiso=%22http://www.opengis.net/cat/csw/apiso/1.0%22%3E%3Cogc:BBOX%3E%3CPropertyName%3Eapiso:BoundingBox%3C/PropertyName%3E%3Cgml:Envelope%3E%3Cgml:lowerCorner%3E-180%2045%3C/gml:lowerCorner%3E%3Cgml:upperCorner%3E180%2090%3C/gml:upperCorner%3E%3C/gml:Envelope%3E%3C/ogc:BBOX%3E%3C/Filter%3E&maxRecords=50&outputFormat=application/xml&outputSchema=http://www.isotc211.org/2005/gmd&request=GetRecords&resultType=results&service=CSW&startPosition=1&version=2.0.2')
        .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/nodc_iso.xml'), headers: {})

      entries = @harvester.get_results_from_nodc(1)
      expect(@harvester.get_docs_with_translated_entries_from_nodc(entries).first.root.first_element_child.name).to eql('doc')
    end

    it 'Issues a request to update Solr with data' do
      stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?commit=true')
        .with(body: Nokogiri.XML('<add><foo></add>').to_xml,
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip, deflate',
                         'Content-Length' => '44',
                         'Content-Type' => 'text/xml; charset=utf-8' })
        .to_return(status: 200, body: 'success', headers: {})

      expect(@harvester.insert_solr_doc(Nokogiri.XML('<add><foo></add>'))).to eql(true)
    end
  end
end
