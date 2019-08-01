require 'spec_helper'
load 'bin/search_solr_tools'

describe SolrHarvestCLI do
  before(:each) do
    @cli = described_class.new
    allow(@cli).to receive(:harvester_map).and_return('adc' => SearchSolrTools::Harvesters::Adc,
                                                      'echo' => SearchSolrTools::Harvesters::Echo,
                                                      'nsidc' => SearchSolrTools::Harvesters::NsidcJson)
  end

  describe '#get_harvester_class' do
    it 'returns the correct harvester class' do
      expect(@cli.get_harvester_class('adc')).to eql SearchSolrTools::Harvesters::Adc
    end
  end

  describe '#harvest' do
    it 'calls the selected harvester classes' do
      puts 'CLI' + @cli.harvester_map.to_s
      [SearchSolrTools::Harvesters::Adc, SearchSolrTools::Harvesters::Echo].each do |harvester_class|
        allow_any_instance_of(harvester_class).to receive(:harvest_and_delete).and_return(true)
        expect_any_instance_of(harvester_class).to receive(:harvest_and_delete)
      end
      @cli.options = { data_center: %w(echo adc), die_on_failure: false, environment: 'dev' }
      @cli.harvest
    end

    # Not testing what it thinks it's testing! The test will pass even if
    # die_on_failure is set to false. die_on_failure is set in response to DCS errors,
    # not non-existing data center errors.
    it 'fails on failure if die_on_failure is true' do
      @cli.options = { data_center: ['not a real datacenter'], die_on_failure: true, environment: 'dev' }
      expect { @cli.harvest }.to raise_exception(SystemExit)
    end
  end

  describe '#delete_by_data_center' do
    it 'calls delete_old_documents on the correct class' do
      @cli.options = { timestamp: '2014-07-14T21:49:21Z', environment: 'dev', data_center: 'adc' }
      allow_any_instance_of(SearchSolrTools::Harvesters::Adc).to receive(:delete_old_documents).and_return(true)
      expect_any_instance_of(SearchSolrTools::Harvesters::Adc).to receive(:delete_old_documents).with(
        '2014-07-14T21:49:21Z',
        'data_centers:"NSF Arctic Data Center"',
        'nsidc_oai',
        true
      )
      @cli.delete_by_data_center
    end
  end
end
