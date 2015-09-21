require 'spec_helper'

describe SearchSolrTools::Harvesters::NcdcPaleo do
  describe '#initialize' do
    def described_method
      described_class.new
    end

    it 'calls the superclass initializer' do
      expect(SearchSolrTools::Harvesters::Base).to receive(:new)
      described_method
    end

    it 'sets the page_size' do
      described_object = described_method
      expect(described_object.instance_variable_get(:@page_size)).to eql(50)
    end

    it 'sets the @translator with the IsoToSolr helper' do
      expect(SearchSolrTools::Helpers::IsoToSolr).to receive(:new).with(:ncdc_paleo).and_return('foo')
      described_object = described_method
      expect(described_object.instance_variable_get(:@translator)).to eql('foo')
    end
  end

  describe '#get_docs_with_translated_entries_from_ncdc_paleo' do
    check_values = {
      'data_centers' => ['NOAA National Oceanographic Data Center'],
      'authors' => ['Hou, X.', 'Li, J.', 'Li, L.', 'Lu, H.', 'Shi, J.', 'Shi, S.', 'Wu, S.'],
      'keywords' => ['Precipitation Reconstruction', 'PIMA', 'Pinus massoniana Lamb.', 'Masson pine', 'earth science/paleoclimate/reconstructions', '(Lower Yangtze River::LATITUDE ::LONGITUDE )'],
      'spatial_coverages' => ['28 116 34 122'],
      'spatial' => ['116 28 122 34'],
      'spatial_area' => ['6.0'],
      'temporal' => ['00.010101 20.150923'],
      'temporal_coverages' => ['1856-01-01T00:00:00+00:00,2013-01-01T00:00:00+00:00'],
      'source' => ['ADE'],
      'facet_data_center' => ['NOAA Paleoclimate data center | NCDC PALEO'],
      'facet_temporal_duration' => ['1+ years', '10+ years', '5+ years'],
      'authoritative_id' => ['{BA24F713-5035-4A21-8EEA-56C162517572}'],
      'dataset_url' => ['http://gis.ncdc.noaa.gov/gptpaleo/catalog/search/resource/details.page?uuid={BA24F713-5035-4A21-8EEA-56C162517572}']
    }

    let(:described_object) { described_class.new }
    let(:entry_list_fixture) { Nokogiri::XML(File.open('spec/unit/fixtures/ncdc_paleo_entry.xml')) }
    let(:entry_fixture) { Nokogiri::XML(File.open('spec/unit/fixtures/ncdc_paleo_csw.xml')) }

    it 'translates_a_document' do
      allow(described_object).to receive(:get_results).with(
        'http://gis.ncdc.noaa.gov/gptpaleo/csw?getxml={BA24F713-5035-4A21-8EEA-56C162517572}',
        '/rdf:RDF/rdf:Description').and_return([entry_fixture])
      doc = described_object.get_docs_with_translated_entries_from_ncdc_paleo([entry_list_fixture.at_xpath('//csw:Record')])
      check_values.each do |key, values|
        translated_values = doc.first.xpath("//field[@name='#{key}']").map(&:text)
        expect(translated_values).to match_array values
      end
    end
  end

  describe '#ncdc_paleo_url' do
    it 'returns the expected URL' do
      harvester = described_class.new('dev')
      expect(harvester.ncdc_paleo_url).to eql('http://gis.ncdc.noaa.gov/gptpaleo/csw')
    end
  end

  describe '#get_results_from_ncdc_paleo_url' do
    it 'calls get_results with a valid csw_request' do
      stub_request(:get, 'http://gis.ncdc.noaa.gov/gptpaleo/csw?ElementSetName=full&TypeNames=gmd:MD_Metadata&maxRecords=50&outputFormat=application/xml&request=GetRecords&resultType=results&service=CSW&startPosition=1&version=2.0.2')
        .with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/xml', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: '', headers: {})
      harvester = described_class.new('dev', true)
      expect_any_instance_of(SearchSolrTools::Harvesters::Base).to receive(:get_results).with(
        'http://gis.ncdc.noaa.gov/gptpaleo/csw?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=50&startPosition=1',
        '//csw:Record').and_return(true)
      harvester.get_results_from_ncdc_paleo_url(1)
    end
  end

  describe '#build_csw_request' do
    it 'returns the expected URL' do
      harvester = described_class.new('dev')
      expect(harvester.build_csw_request).to eql('http://gis.ncdc.noaa.gov/gptpaleo/csw?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=1000&startPosition=1')
    end
  end
end
