require 'spec_helper'

describe SearchSolrTools::Harvesters::Nmi do
  describe '#initialize' do
    it 'subclasses ADE' do
      expect(described_class.superclass).to eql SearchSolrTools::Harvesters::ADE
    end
    it 'should call initialize with EOL as the profile name' do
      expect_any_instance_of(SearchSolrTools::Harvesters::ADE).to receive(:initialize).with('integration', 'NMI', false)
      described_class.new('integration', false)
    end
  end
end
