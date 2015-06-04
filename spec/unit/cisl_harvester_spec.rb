require File.join('.', 'config', 'environments.rb')
require 'webmock/rspec'
require 'cisl_harvester'
require 'json'

require_relative '../../lib/selectors/helpers/iso_namespaces'

describe CislHarvester do
  before(:each) do
    @harvester = described_class.new(:dev)
  end

  describe '#initialize' do
    it 'has a @dataset instance variable' do
      expect(@harvester.instance_variable_defined?(:@dataset)).to be_true
      expect(@harvester.instance_variable_get(:@dataset)).to eql '0bdd2d39-3493-4fa2-98f9-6766596bdc50'
    end

    it 'has a @data_centers instance variable' do
      expect(@harvester.instance_variable_defined?(:@data_centers)).to be_true
      expect(@harvester.instance_variable_get(:@data_centers)).to eql 'Advanced Cooperative Arctic Data and Information Service'
    end

    it 'has a @translator instance variable' do
      expect(@harvester.instance_variable_defined?(:@translator)).to be_true
    end
  end

  describe '#metadata_url' do
    it 'is set to the Polar Data Catalogue feed URL' do
      expect(@harvester.metadata_url).to eql 'https://www.aoncadis.org/oai/repository'
    end
  end

  describe '#results' do
    def described_method
      @harvester.results
    end

    before(:each) do
      doc = Nokogiri.XML(File.open('spec/unit/fixtures/cisl_oai.xml'))
      fixture = doc.xpath('//oai:ListRecords', IsoNamespaces.namespaces(doc))

      allow(@harvester).to receive(:get_results).and_return(fixture)
    end

    it 'returns an array of Nokogiri elements' do
      expect(described_method.length).to eql 1
      expect(described_method.first.class).to eql Nokogiri::XML::Element
    end

    it 'sets the resumption token' do
      described_method

      expect(@harvester.instance_variable_get(:@resumption_token)).to eql({
        from: nil,
        until: nil,
        set: '0bdd2d39-3493-4fa2-98f9-6766596bdc50',
        metadataPrefix: 'dif',
        offset: '100'
      }.to_json)
    end
  end
end
