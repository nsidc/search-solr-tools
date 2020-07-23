require 'spec_helper'

describe SearchSolrTools::Harvesters::R2R, :skip => "Obsolete harvester, would need to be updated to new status handling method" do
  before(:each) do
    @harvester = described_class.new(:dev)
  end
  describe '#initialize' do
    it 'has a @data_centers instance variable' do
      expect(@harvester.instance_variable_defined?(:@data_centers)).to eql true
      expect(@harvester.instance_variable_get(:@data_centers)).to eql 'Rolling Deck to Repository'
    end

    it 'has a @translator instance variable' do
      expect(@harvester.instance_variable_defined?(:@translator)).to eql true
    end

    it 'has a @metadata_url instance variable' do
      expect(@harvester.instance_variable_defined?(:@metadata_url)).to eql true
      expect(@harvester.instance_variable_get(:@metadata_url)).to eql 'http://get.rvdata.us/services/cruise/'
    end
  end
end
