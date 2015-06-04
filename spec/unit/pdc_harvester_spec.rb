require File.join('.', 'config', 'environments.rb')
require 'webmock/rspec'
require 'pdc_harvester'

require_relative '../../lib/selectors/helpers/iso_namespaces'

describe PdcHarvester do
  before(:each) do
    @harvester = described_class.new(:dev)
  end

  it 'has a @data_centers class variable' do
    expect(described_class.instance_variable_defined?(:@data_centers)).to be_true
    expect(described_class.instance_variable_get(:@data_centers)).to eql 'Polar Data Catalogue'
  end

  it 'has a @translator class variable' do
    expect(described_class.instance_variable_defined?(:@translator)).to be_true
  end

  describe '#metadata_url' do
    it 'is set to the Polar Data Catalogue feed URL' do
      expect(@harvester.metadata_url).to eql 'http://www.polardata.ca/oai/provider'
    end
  end

  describe '#results' do
    def described_method
      @harvester.results
    end

    before(:each) do
      doc = Nokogiri.XML(File.open('spec/unit/fixtures/pdc_oai.xml'))
      fixture = doc.xpath('//oai:ListRecords', IsoNamespaces.namespaces(doc))

      allow(@harvester).to receive(:get_results).and_return(fixture)
    end

    it 'returns an array of Nokogiri elements' do
      expect(described_method.length).to eql 1
      expect(described_method.first.class).to eql Nokogiri::XML::Element
    end

    it 'sets the resumption token' do
      described_method
      expect(@harvester.instance_variable_get(:@resumption_token)).to eql '0/300/1928/iso/null/null/null'
    end
  end

  describe '#request_string' do
    def described_method
      @harvester.send(:request_string)
    end

    it 'contains the metadata url' do
      expect(described_method).to match 'http://www.polardata.ca/oai/provider?'
    end

    it 'contains a verb set to "ListRecords"' do
      expect(described_method).to match 'verb=ListRecords'
    end

    describe 'with a nil resumption token' do
      before(:each) do
        @harvester.instance_variable_set(:@resumption_token, nil)
      end

      it 'contains a metadataPrefix set to "iso"' do
        expect(described_method).to match 'metadataPrefix=iso'
      end

      it 'contains no resumptionToken' do
        expect(described_method).not_to match 'resumptionToken'
      end
    end

    describe 'with a non-nil resumption token' do
      before(:each) do
        @harvester.instance_variable_set(:@resumption_token, 'token')
      end

      it 'contains no metadataPrefix' do
        expect(described_method).not_to match 'metadataPrefix'
      end

      it 'contains the resumptionToken' do
        expect(described_method).to match 'resumptionToken=token'
      end
    end
  end
end
