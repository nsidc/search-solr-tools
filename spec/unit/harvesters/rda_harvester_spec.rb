require 'spec_helper'

describe SearchSolrTools::Harvesters::Rda, :skip => "Obsolete harvester, would need to be updated to new status handling method" do
  before(:each) do
    @harvester = described_class.new(:dev)
  end

  describe '#initialize' do
    it 'has a @data_centers instance variable' do
      expect(@harvester.instance_variable_defined?(:@data_centers)).to eql true
      expect(@harvester.instance_variable_get(:@data_centers)).to eql 'UCAR NCAR Research Data Archive'
    end

    it 'has a @translator instance variable' do
      expect(@harvester.instance_variable_defined?(:@translator)).to eql true
    end
  end

  describe '#metadata_url' do
    it 'is set to the Polar Data Catalogue feed URL' do
      expect(@harvester.metadata_url).to eql 'https://rda.ucar.edu/cgi-bin/oai'
    end
  end

  describe '#results' do
    def described_method
      @harvester.results
    end

    before(:each) do
      doc = Nokogiri.XML(File.open('spec/unit/fixtures/rda_oai.xml'))
      fixture = doc.xpath('//oai:ListRecords', SearchSolrTools::Helpers::IsoNamespaces.namespaces(doc))

      allow(@harvester).to receive(:get_results).and_return(fixture)
    end

    it 'returns an array of Nokogiri elements' do
      expect(described_method.length).to eql 1
      expect(described_method.first.class).to eql Nokogiri::XML::Element
    end

    it 'sets resumption token to an empty value so the harvest stops' do
      described_method
      expect(@harvester.instance_variable_get(:@resumption_token)).to eql ''
    end
  end

  describe '#request_params' do
    def described_method
      @harvester.send(:request_params)
    end

    it 'sets the verb and metadata prefix' do
      expect(described_method).to eql(verb: 'ListRecords', metadataPrefix: 'dif')
    end
  end
end
