require 'spec_helper'

describe SearchSolrTools::Harvesters::DataOne, :skip => "Obsolete harvester, would need to be updated to new status handling method" do
  describe '#initialize' do
    def described_method
      described_class.new
    end

    it 'calls the superclass intializer' do
      expect(SearchSolrTools::Harvesters::Base).to receive(:new)
      described_method
    end

    it 'sets the @page_size' do
      described_object = described_method
      expect(described_object.instance_variable_get(:@page_size)).to eql(250)
    end

    it 'sets the @translator with the IsoToSolr helper' do
      expect(SearchSolrTools::Helpers::IsoToSolr).to receive(:new).with(:data_one).and_return('something')

      described_object = described_method
      expect(described_object.instance_variable_get(:@translator)).to eql('something')
    end
  end

  describe '#get_docs_with_translated_entries_from_data_one' do
    check_values = {
      'data_centers' => ['DataONE'],
      'authors' => ['George Kling'],
      'keywords' => ['CH4', 'CO2', 'DIC', 'Dissolved inorganic carbon', 'carbon dioxide', 'methane'],
      'spatial_coverages' => ['68.64762 -149.5773 68.64762 -149.5773'],
      'spatial' => ['-149.5773 68.64762'],
      'spatial_area' => ['0.0'],
      'temporal' => ['20.000630 20.000714'],
      'temporal_coverages' => ['2000-06-30T00:00:00Z,2000-07-14T00:00:00Z'],
      'source' => ['ADE'],
      'facet_data_center' => ['DataONE | DataONE'],
      'facet_temporal_duration' => ['< 1 year'],
      'authoritative_id' => ['knb-lter-arc.10353.1'],
      'dataset_url' => ['https://cn.dataone.org/cn/v1/resolve/knb-lter-arc.10353.1'],
      'last_revision_date' => ['2013-10-20T23:00:00Z'],
      'temporal_duration' => ['15'],
      'facet_spatial_scope' => ['Less than 1 degree of latitude change | Local']
    }

    let(:described_object) { described_class.new }
    let(:entry_list_fixture) { Nokogiri::XML(File.open('spec/unit/fixtures/data_one.xml')) }
    let(:entry_fixture) { Nokogiri::XML(File.open('spec/unit/fixtures/data_one_entry.xml')) }

    before(:each) do
      allow(described_object).to(
        receive(:get_results).with(
          'https://cn.dataone.org/cn/v1/query/solr/select?q=northBoundCoord:%5B45.0%20TO%2090.1%5D'\
          '&start=0&rows=250',
          './response/result/doc'
        ).and_return([entry_fixture])
      )
    end

    check_values.each do |key, values|
      it "translates '#{key}' from the document" do
        doc = described_object.get_docs_with_translated_entries_from_data_one([entry_list_fixture.at_xpath('//doc')])
        translated_values = doc.first.xpath("//field[@name='#{key}']").map(&:text)
        expect(translated_values).to match_array(values)
      end
    end
  end

  describe '#metadata_url' do
    before(:each) do
      allow(SearchSolrTools::SolrEnvironments).to(
        receive(:[]).and_return(data_one_url: 'data_one_url')
      )
    end

    it 'returns the url from the Solr Environments' do
      expect(described_class.new.metadata_url).to eql('data_one_url')
    end
  end

  describe '#build_request' do
    let(:described_object) { described_class.new }

    def described_method(start = 0, max_records = 100)
      described_object.build_request(start, max_records)
    end

    before(:each) do
      allow(described_object).to receive(:metadata_url).and_return('http://www.example.com/query?')
    end

    it 'adds the start and rows parameters to the url' do
      expect(described_method(12, 35)).to eql('http://www.example.com/query?&start=12&rows=35')
    end
  end
end
