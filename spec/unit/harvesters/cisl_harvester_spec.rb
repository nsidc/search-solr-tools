require 'json'
require 'nokogiri'

require 'search_solr_tools/harvesters/cisl'
require 'search_solr_tools/helpers/iso_namespaces'

describe CislHarvester do
  before(:each) do
    @harvester = described_class.new(:dev)
  end

  describe '#initialize' do
    it 'has a @dataset instance variable' do
      expect(@harvester.instance_variable_defined?(:@dataset)).to eql true
      expect(@harvester.instance_variable_get(:@dataset)).to eql '0bdd2d39-3493-4fa2-98f9-6766596bdc50'
    end

    it 'has a @data_centers instance variable' do
      expect(@harvester.instance_variable_defined?(:@data_centers)).to eql true
      expect(@harvester.instance_variable_get(:@data_centers)).to eql 'Advanced Cooperative Arctic Data and Information Service'
    end

    it 'has a @translator instance variable' do
      expect(@harvester.instance_variable_defined?(:@translator)).to eql true
    end
  end

  describe '#metadata_url' do
    it 'is set to the Polar Data Catalogue feed URL' do
      expect(@harvester.metadata_url).to eql 'https://www.aoncadis.org/oai/repository'
    end
  end

  describe '#request_params' do
    it 'contains a verb, metadatPrefix, and set' do
      expected = {
        verb: 'ListRecords',
        metadataPrefix: 'dif',
        set: '0bdd2d39-3493-4fa2-98f9-6766596bdc50'
      }
      expect(@harvester.send(:request_params)).to eql expected
    end

    it 'contains a resumption token if set' do
      @harvester.instance_variable_set(:@resumption_token, 'token')

      expected = {
        verb: 'ListRecords',
        metadataPrefix: 'dif',
        set: '0bdd2d39-3493-4fa2-98f9-6766596bdc50',
        resumptionToken: 'token'
      }
      expect(@harvester.send(:request_params)).to eql expected
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

  describe '#format_resumption_token' do
    def described_method(token)
      @harvester.send(:format_resumption_token, token)
    end

    before(:each) do
      @harvester.instance_variable_set(:@dataset, 'test dataset')
    end

    it 'returns the empty string if the token is empty' do
      expect(described_method('')).to eql ''
    end

    it 'returns a JSON string containing the offset' do
      token = 'offset:12345'
      actual = described_method(token)

      expected = {
        from: nil,
        until: nil,
        set: 'test dataset',
        metadataPrefix: 'dif',
        offset: '12345'
      }.to_json

      expect(actual).to eql expected
    end

    it 'returns a JSON string with a null offset' do
      token = 'no offset here'
      actual = described_method(token)

      expected = {
        from: nil,
        until: nil,
        set: 'test dataset',
        metadataPrefix: 'dif',
        offset: nil
      }.to_json

      expect(actual).to eql expected
    end
  end
end
