require 'spec_helper'

describe SearchSolrTools::Harvesters::Adc do
  before(:each) do
    @harvester = described_class.new(:dev)
  end

  describe '#initialize' do
    it 'has a @page_size instance variable' do
      expect(@harvester.instance_variable_defined?(:@page_size)).to eql true
      expect(@harvester.instance_variable_get(:@page_size)).to eql 250
    end

    it 'has a @translator instance variable' do
      expect(@harvester.instance_variable_defined?(:@translator)).to eql true
    end
  end

  describe '#metadata_url' do
    it 'is set to the arctic data center feed URL' do
      expect(@harvester.metadata_url).to eql 'https://knb.ecoinformatics.org/knb/d1/mn/v2/query/solr/'
    end
  end
end
