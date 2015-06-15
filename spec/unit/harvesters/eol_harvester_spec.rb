require 'spec_helper'

describe SearchSolrTools::Harvesters::Eol do
  describe '#initialize' do
    it 'subclasses ADE' do
      expect(described_class.superclass).to eql SearchSolrTools::Harvesters::ADE
    end
    it 'should call superclass initialize with EOL as the profile name' do
      expect_any_instance_of(SearchSolrTools::Harvesters::ADE).to receive(:initialize).with('integration', 'EOL', false)
      described_class.new('integration', false)
    end
  end
end
