require 'spec_helper'
require_relative '../../lib/search_solr_tools/bin/solr_tools'

describe SolrHarvestCLI do
  before(:each) do
    @cli = described_class.new
    allow(@cli).to receive(:harvester_map).and_return('cisl' => 'Cisl',
                                                      'echo' => 'Echo',
                                                      'nsidc' => 'NsidcJson')
  end

  describe '#get_harvester_class' do
    it 'returns the correct harvester class' do
      expect(@cli.get_harvester_class('cisl')).to eql SearchSolrTools::Harvesters::Cisl
    end
  end

  describe '#harvester_class_name' do
    it 'returns the correct harvester class name' do
      expect(@cli.harvester_class_name('nsidc')).to eql('NsidcJson')
    end
  end

  describe '#harvest' do
    it 'calls the selected harvester classes' do
      puts 'CLI' + @cli.harvester_map.to_s
      [SearchSolrTools::Harvesters::Cisl, SearchSolrTools::Harvesters::Echo].each do |harvester_class|
        allow_any_instance_of(harvester_class).to receive(:harvest_and_delete).and_return(true)
        expect_any_instance_of(harvester_class).to receive(:harvest_and_delete)
      end
      @cli.options = { from: %w(echo cisl), die_on_failure: false, environment: 'dev' }
      @cli.harvest
    end

    it 'fails on failure if die_on_failure is true' do
      @cli.options = { from: ['not a real datacenter'], die_on_failure: false, environment: 'dev' }
      expect { @cli.harvest }.to_not raise_exception
    end

    it 'fails on failure if die_on_failure is true' do
      @cli.options = { from: ['not a real datacenter'], die_on_failure: true, environment: 'dev' }
      expect { @cli.harvest }.to raise_exception(RuntimeError)
    end
  end

  describe '#delete_by_data_center' do
    it 'calls delete_old_documents on the correct class' do
      @cli.options = { timestamp: '2014-07-14T21:49:21Z', environment: 'dev', from: 'cisl' }
      allow_any_instance_of(SearchSolrTools::Harvesters::Cisl).to receive(:delete_old_documents).and_return(true)
      expect_any_instance_of(SearchSolrTools::Harvesters::Cisl).to receive(:delete_old_documents).with('2014-07-14T21:49:21Z', "data_centers:\"Advanced Cooperative Arctic Data and Information Service\"", 'nsidc_oai', true)
      @cli.delete_by_data_center
    end
  end

  describe '#list_harvesters' do
    it 'returns the list of harvesters' do
      expect(@cli.list_harvesters).to eql('cisl' => 'Cisl', 'echo' => 'Echo', 'nsidc' => 'NsidcJson')
    end
  end
end