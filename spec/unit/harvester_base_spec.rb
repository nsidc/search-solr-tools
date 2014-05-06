require 'webmock/rspec'
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

  it 'serializes a hash and adds it to solr in JSON format' do
    harvester = described_class.new 'integration'
    add_doc = { 'add' => { 'doc' => { 'authoritative_id' => 'TEST-0001' } } }
    serialized_add_doc = "{\"add\":{\"doc\":{\"authoritative_id\":\"TEST-0001\"}}}"

    stub_request(:post, 'http://localhost:9283/solr/update?commit=true')
    .with(body: serialized_add_doc,
          headers: {
              'Accept' => '*/*; q=0.5, application/xml',
              'Accept-Encoding' => 'gzip, deflate',
              'Content-Length' => '48',
              'Content-Type' => HarvesterBase::JSON_CONTENT_TYPE,
              'User-Agent' => 'Ruby' })
    .to_return(status: 200, body: 'success', headers: {})

    harvester.insert_solr_doc(add_doc, HarvesterBase::JSON_CONTENT_TYPE).should eql(true)
  end

  it 'serializes an XML add document and adds it to solr in XML format' do
    harvester = described_class.new 'integration'
    add_doc = Nokogiri.XML('<add><doc><field name="authoritative_id">TEST-0001</field></doc></add>')
    stub_request(:post, 'http://localhost:9283/solr/update?commit=true')
    .with(body: add_doc.to_xml,
          headers: {
              'Accept' => '*/*; q=0.5, application/xml',
              'Accept-Encoding' => 'gzip, deflate',
              'Content-Length' => '105',
              'Content-Type' => HarvesterBase::XML_CONTENT_TYPE,
              'User-Agent' => 'Ruby' })
    .to_return(status: 200, body: 'success', headers: {})

    harvester.insert_solr_doc(add_doc).should eql(true)
  end

  describe 'insert_solr_docs' do
    it 'raises an error if some documents are not successfully added' do
      harvester = described_class.new 'integration'
      allow(harvester).to receive('insert_solr_doc').and_return(false, true)

      expect { harvester.insert_solr_docs(%w(doc1 doc2 doc3)) }.to raise_error
    end
  end
end
