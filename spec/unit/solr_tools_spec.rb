require 'spec_helper'
load 'bin/search_solr_tools'

describe SolrHarvestCLI do
  before(:each) do
    @cli = described_class.new
    allow(@cli).to receive(:harvester_map).and_return('cisl' => SearchSolrTools::Harvesters::Cisl,
                                                      'echo' => SearchSolrTools::Harvesters::Echo,
                                                      'nsidc' => SearchSolrTools::Harvesters::NsidcJson)
  end

  describe '#get_harvester_class' do
    it 'returns the correct harvester class' do
      expect(@cli.get_harvester_class('cisl')).to eql SearchSolrTools::Harvesters::Cisl
    end
  end

  describe '#harvest' do
    it 'calls the selected harvester classes' do
      puts 'CLI' + @cli.harvester_map.to_s
      [SearchSolrTools::Harvesters::Cisl, SearchSolrTools::Harvesters::Echo].each do |harvester_class|
        allow_any_instance_of(harvester_class).to receive(:harvest_and_delete).and_return(true)
        expect_any_instance_of(harvester_class).to receive(:harvest_and_delete)
      end
      @cli.options = { data_center: %w(echo cisl), die_on_failure: false, environment: 'dev' }
      @cli.harvest
    end

    it 'does not fail on failure if die_on_failure is false' do
      @cli.options = { data_center: ['not a real datacenter'], die_on_failure: false, environment: 'dev' }
      expect { @cli.harvest }.to_not raise_exception
    end

    it 'fails on failure if die_on_failure is true' do
      @cli.options = { data_center: ['not a real datacenter'], die_on_failure: true, environment: 'dev' }
      expect { @cli.harvest }.to raise_exception(RuntimeError)
    end
  end

  describe '#delete_by_data_center' do
    it 'calls delete_old_documents on the correct class' do
      @cli.options = { timestamp: '2014-07-14T21:49:21Z', environment: 'dev', data_center: 'cisl' }
      allow_any_instance_of(SearchSolrTools::Harvesters::Cisl).to receive(:delete_old_documents).and_return(true)
      expect_any_instance_of(SearchSolrTools::Harvesters::Cisl).to receive(:delete_old_documents).with(
        '2014-07-14T21:49:21Z', "data_centers:\"Advanced Cooperative Arctic Data and Information Service\"",
        'nsidc_oai', true)
      @cli.delete_by_data_center
    end
  end
end
