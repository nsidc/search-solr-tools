require 'harvester_base'

describe HarvesterBase do
  describe 'Initialization' do
    it 'Uses a default environment if not specified' do
      harvester = HarvesterBase.new
      expect(harvester.environment).to eq('development')
    end

    it 'Initializes with a specific environment name' do
      harvester = HarvesterBase.new('qa')
      expect(harvester.environment).to eq('qa')
    end
  end

  it 'Builds a new Nokogiri XML document with an "add" root node' do
    doc = HarvesterBase.new.create_new_solr_add_doc
    expect(doc.root.name).to eql('add')
    expect(doc.to_xml).to eql("<?xml version=\"1.0\"?>\n<add/>\n")
  end
end