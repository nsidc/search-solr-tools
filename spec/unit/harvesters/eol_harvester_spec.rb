require 'spec_helper'

describe SearchSolrTools::Harvesters::Eol do
  before :all do
    @harvester = described_class.new
    @translation = {
      'title' => 'Buoy: IABP Daily Buoy Positions [Moritz, R.]',
      'authoritative_id' => 'ucar.ncar.eol.dataset.13_453',
      'data_centers' => 'UCAR NCAR - Earth Observing Laboratory',
      'facet_data_center' => 'UCAR NCAR - Earth Observing Laboratory | UCAR NCAR EOL',
      'summary' => "During SHEBA, the Polar Science Center at the University of Washington deployed a network of automatic
buoys for monitoring synoptic-scale fields of pressure, temperature, and ice motion throughout the Arctic Basin. This dataset contains the daily buoy positions. For more information, please see the readme file.", 'temporal_coverages' => ['1997-12-31,1998-12-31'], 'temporal_duration' => 365, 'temporal' => ['19.971231 19.981231'], 'facet_temporal_duration' => ['1+ years'], "last_revisi
on_date" => '2007-11-05T04:12:58Z',
      'source' => 'ADE',
      'keywords' => %w(Arctic Surface),
      'authors' => 'Richard Moritz',
      'dataset_url' => 'http://data.eol.ucar.edu/codiac/dss/id=13.453',
      'facet_spatial_coverage' => false, 'facet_spatial_scope' => 'Between 1 and 170 degrees of latitude change | Regional',
      'spatial_coverages' => '70.0 -170.0 80.0 -130.0',
      'spatial_area' => 10.0,
      'spatial' => '-170.0 70.0 -130.0 80.0'
    }
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

  describe '#initialize' do
    it 'has a translator instance variable' do
      expect(@harvester.instance_variable_defined?(:@translator)).to eql true
    end

    it 'calls the superclass initialize method' do
      expect_any_instance_of(SearchSolrTools::Harvesters::Base).to receive(:initialize).with('integration', true)
      described_class.new('integration', true)
    end
  end

  describe '#harvest_eol_into_solr' do
    before :each do
      @thredds_metadata = Nokogiri::XML(File.open(File.expand_path('../../../unit/fixtures/eol_thredds_106_295.thredds.xml', __FILE__)))
      @dataset_metadata = Nokogiri::XML(File.open(File.expand_path('../../../unit/fixtures/eol_thredds_106_295.metadata.xml', __FILE__)))
      allow_any_instance_of(described_class).to receive(:eol_dataset_urls).and_return(['http://test_url.xml'])
      @harvester = described_class.new('development', true)
    end

    it 'inserts a translated document' do
      allow_any_instance_of(SearchSolrTools::Translators::EolToSolr).to receive(:translate).and_return(@translation)
      allow_any_instance_of(described_class).to receive(:open_xml_document).and_return(Nokogiri::XML(%(
        <TEST xmlns="TEST">
          <metadata xlink:href='http://test_dataset.thredds.xml'>
      )))
      expect_any_instance_of(SearchSolrTools::Harvesters::Base).to receive(:insert_solr_docs).with(
        [{ 'add' => { 'doc' => @translation } }], SearchSolrTools::Harvesters::Base::JSON_CONTENT_TYPE
      ).and_return true
      @harvester.harvest_eol_into_solr
    end

    it 'fails when complex metadata is encountered' do
      allow_any_instance_of(described_class).to receive(:open_xml_document).and_return(Nokogiri::XML(%(
        <TEST xmlns="TEST">
          <metadata xlink:href='http://test_dataset.thredds.xml'>
          <metadata xlink:href='http://test_dataset2.thredds.xml'>
      )))
      expect { @harvester.harvest_eol_into_solr }.to raise_error(RuntimeError)
    end

    it 'continue on failure if die_on_failure is false' do
      @harvester = described_class.new('development', false)
      allow_any_instance_of(described_class).to receive(:open_xml_document).and_return(Nokogiri::XML(%(
        <TEST xmlns="TEST">
          <metadata xlink:href='http://test_dataset.thredds.xml'>
          <metadata xlink:href='http://test_dataset2.thredds.xml'>
      )))
      expect_any_instance_of(SearchSolrTools::Harvesters::Base).to receive(:insert_solr_docs).and_return true
      @harvester.harvest_eol_into_solr
    end
  end
end
