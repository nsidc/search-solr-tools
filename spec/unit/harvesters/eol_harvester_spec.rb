require 'spec_helper'

describe SearchSolrTools::Harvesters::Eol do
  before :all do
    @harvester = described_class.new
  end

  describe '#eol_dataset_urls' do
    before :each do
      allow(SearchSolrTools::SolrEnvironments).to receive(:[]).and_return(
        eol: ['foo.thredds.xml'],
        development: {}
      )
      allow_any_instance_of(described_class).to receive(:open_xml_document).and_return(
        Nokogiri::XML(File.open(File.expand_path(
                                  '../../fixtures/eol_thredds_project.xml', __FILE__)
                               )
                     ))
    end

    it 'Returns a list of dataset_urls' do
      expect(@harvester.eol_dataset_urls).to eql(
        ['http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.dataset.13_612.thredds.xml',
         'http://data.eol.ucar.edu/jedi/catalog/ucar.ncar.eol.dataset.13_602.thredds.xml'])
    end
  end

  describe '#open_xml_document' do
    before :all do
      @doc_url = 'http://some.api.for.data.xml'
      stub_request(:get, @doc_url).to_return(body: File.open(File.expand_path('../../../unit/fixtures/eol_thredds_106_295.thredds.xml', __FILE__)), status: 200)
    end

    it 'opens an xml document given a URL' do
      expect(@harvester.open_xml_document(@doc_url)).to be_kind_of(Nokogiri::XML::Document)
    end
  end

  describe 'initialize' do
    it 'has a translator instance variable' do
      expect(@harvester.instance_variable_defined?(:@translator)).to eql true
    end

    it 'calls the superclass initialize method' do
      expect_any_instance_of(SearchSolrTools::Harvesters::Base).to receive(:initialize).with('integration', true)
      described_class.new('integration', true)
    end
  end

  describe '#harvest_eol_into_solr' do
    it 'inserts a translated document' do
    end
  end
end
