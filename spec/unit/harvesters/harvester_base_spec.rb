require 'spec_helper'

describe SearchSolrTools::Harvesters::Base do
  describe '#sanitize_data_centers_constraints' do
    it 'Removes all lucene chars' do
      test_string = '1+ 2  -  3&&  4| 5|6!7 8(  9)   10  11{ 12} 13[ 14]15 '\
                    '16+  ^17   ~18  *19  ?  20:    21'
      expect(described_class.new.sanitize_data_centers_constraints(test_string)).to eql [*1...22].join(' ')
    end

    it 'Retains the data_centers query seperator' do
      test_string = 'data_centers:"one| {} two [three]"'
      expect(described_class.new.sanitize_data_centers_constraints(test_string)).to eql('data_centers:"one two three "')
    end
  end

  describe 'Initialization' do
    it 'Uses a default environment if not specified' do
      harvester = described_class.new
      expect(harvester.environment).to eq('development')
    end

    it 'Initializes with a specific environment name' do
      harvester = described_class.new('qa')
      expect(harvester.environment).to eq('qa')
    end
  end

  describe '#get_results' do
    describe 'with @die_on_failure ' do
      let(:described_object) { described_class.new('development', true) }

      def described_method_get_results(request_url, metadata_path, content_type = 'application/xml')
        described_object.get_results(request_url, metadata_path, content_type)
      end

      describe 'with a successful response' do
        let(:nokogiri) { double(Nokogiri) }
        let(:doc) { double('doc') }
        let(:parsed_metadata) { double('parsed_metadata') }

        before(:each) do
          response = double('response')
          allow(described_object).to receive(:open).and_return(response)
          allow(nokogiri).to receive(:XML).and_return(doc)
          allow(doc).to receive(:xpath).and_return(parsed_metadata)
        end

        it 'returns metadata from the XML response' do
          expect do
            described_method_get_results(
              'http://www.polardata.ca/oai/provider?verb=ListRecords&metadataPrefix=iso',
              '/metadata/xpath'
            ).to eql(parsed_metadata)
          end
        end
      end

      describe 'with error OpenURI::HTTPError' do
        before(:each) do
          exception_io = double('io')
          exception_io.stub_chain(:status, :[]).with(0).and_return('302')

          allow(described_object).to receive(:open).and_raise(OpenURI::HTTPError.new('', exception_io))
        end

        it 'makes 3 attempts before propagating the error' do
          expect(described_object).to receive(:open).exactly(3).times
          expect do
            described_method_get_results(
              'http://www.polardata.ca/oai/provider?verb=ListRecords&metadataPrefix=iso',
              '/metadata/xpath'
            )
          end.to raise_error(OpenURI::HTTPError)
        end
      end

      [Timeout::Error, Errno::ETIMEDOUT].each do |err_type|
        describe "with error #{err_type}" do
          before(:each) do
            allow(described_object).to receive(:open).and_raise(err_type)
          end

          it 'makes 3 attempts before propagating the error' do
            expect(described_object).to receive(:open).exactly(3).times
            expect do
              described_method_get_results(
                'http://www.polardata.ca/oai/provider?verb=ListRecords&metadataPrefix=iso',
                '/metadata/xpath'
              )
            end.to raise_error(err_type)
          end
        end
      end
    end
  end

  it 'Builds a new Nokogiri XML document with an "add" root node' do
    doc = described_class.new.create_new_solr_add_doc
    expect(doc.root.name).to eql('add')
    expect(doc.to_xml).to eql("<?xml version=\"1.0\"?>\n<add/>\n")
  end

  it 'serializes a hash and adds it to solr in JSON format' do
    harvester = described_class.new 'integration'
    add_doc = { 'add' => { 'doc' => { 'authoritative_id' => 'TEST-0001' } } }
    serialized_add_doc = '{"add":{"doc":{"authoritative_id":"TEST-0001"}}}'

    stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?commit=true')
      .with(body: serialized_add_doc,
            headers: { 'Accept' => '*/*',
                       'Accept-Encoding' => GZIP_DEFLATE_IDENTITY,
                       'Content-Length' => '48',
                       'Content-Type' => described_class::JSON_CONTENT_TYPE })
      .to_return(status: 200, body: 'success', headers: {})

    expect(harvester.insert_solr_doc(add_doc, described_class::JSON_CONTENT_TYPE)).to eql(SearchSolrTools::Helpers::HarvestStatus::INGEST_OK)
  end

  it 'serializes an XML add document and adds it to solr in XML format' do
    harvester = described_class.new 'integration'
    add_doc = Nokogiri.XML('<add><doc><field name="authoritative_id">TEST-0001</field></doc></add>')
    stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?commit=true')
      .with(body: add_doc.to_xml,
            headers: { 'Accept' => '*/*',
                       'Accept-Encoding' => GZIP_DEFLATE_IDENTITY,
                       'Content-Length' => '105',
                       'Content-Type' => described_class::XML_CONTENT_TYPE })
      .to_return(status: 200, body: 'success', headers: {})

    expect(harvester.insert_solr_doc(add_doc)).to eql(SearchSolrTools::Helpers::HarvestStatus::INGEST_OK)
  end

  describe 'harvest_and_delete' do
    before :each do
      @harvester = described_class.new 'integration'
      expect(@harvester).to receive(:harvest).at_least(:once)
    end

    it 'adds documents and then deletes documents that were not updated' do
      stubs = stub_update_and_delete(500, 10)
      @harvester.harvest_and_delete(@harvester.method(:harvest), 'data_centers:"test"')

      expect(stubs[:delete_stub]).to have_been_requested
      expect(stubs[:commit_stub]).to have_been_requested
    end

    it 'Does not delete documents when more then .1 of documents are not updated' do
      stubs = stub_update_and_delete(500, 75)
      @harvester.harvest_and_delete(@harvester.method(:harvest), 'data_centers:"test"')

      expect(stubs[:delete_stub]).to_not have_been_requested
      expect(stubs[:commit_stub]).to_not have_been_requested
    end

    it 'Does not delete documents when none exist' do
      stubs = stub_update_and_delete(0, 0)
      @harvester.harvest_and_delete(@harvester.method(:harvest), 'data_centers:"test"')

      expect(stubs[:delete_stub]).to_not have_been_requested
      expect(stubs[:commit_stub]).to_not have_been_requested
    end
  end

  describe 'delete_old_documents' do
    before :each do
      @harvester = described_class.new 'integration'
    end

    it 'Can be forced to delete with a timestamp' do
      stubs = stub_update_and_delete(500, 75)
      @harvester.delete_old_documents('20040202', 'data_centers:"test"', SearchSolrTools::SolrEnvironments[@harvester
.environment][:collection_name], true)

      expect(stubs[:delete_stub]).to have_been_requested
      expect(stubs[:commit_stub]).to have_been_requested
    end
  end

  describe 'ingest' do
    let (:invalid_doc) { SearchSolrTools::Helpers::HarvestStatus::INGEST_ERR_INVALID_DOC }
    let (:ingest_fail) { SearchSolrTools::Helpers::HarvestStatus::INGEST_ERR_SOLR_ERROR }
    let (:ingest_ok)  { SearchSolrTools::Helpers::HarvestStatus::INGEST_OK }
    let (:harvester) { described_class.new 'integration' }

    describe 'insert_solr_docs' do
      it 'returns a status object reporting errors if some documents are not successfully added' do
        allow(harvester).to receive('insert_solr_doc').and_return(ingest_fail, invalid_doc, ingest_ok)

        res = harvester.insert_solr_docs(%w(doc1 doc2 doc3))
        expect(res.ok?).to eql(false)
        expect(res.documents_with_status(ingest_fail).size).to eql(1)
        expect(res.documents_with_status(ingest_ok).size).to eql(1)
        expect(res.documents_with_status(invalid_doc).size).to eql(1)
      end

      it 'returns a status object reporting no errors if all documents were successfully added' do
        allow(harvester).to receive('insert_solr_doc').and_return(ingest_ok)

        res = harvester.insert_solr_docs(%w(doc1 doc2 doc3))
        expect(res.ok?).to eql(true)
        expect(res.documents_with_status(ingest_fail).size).to eql(0)
        expect(res.documents_with_status(ingest_ok).size).to eql(3)
        expect(res.documents_with_status(invalid_doc).size).to eql(0)
      end
    end

    describe 'insert_solr_doc' do
      before(:each) do
        stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?commit=true')
            .with{ |request| request.body.include? 'good_doc' }
            .to_return(status: 200, body: 'success', headers: {})

        stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?commit=true')
            .with{ |request| request.body.include? 'bad_doc' }
            .to_return(status: 500, body: 'failure', headers: {})
      end

      it 'returns invalid document status if validation check fails' do
        allow(harvester).to receive('doc_valid?').and_return(false)

        expect(harvester.insert_solr_doc('doc')).to eql(invalid_doc)
      end

      it 'returns solr error status if valid xml doc does not ingest correctly' do
        allow(harvester).to receive('doc_valid?').and_return(true)

        expect(harvester.insert_solr_doc('bad_doc')).to eql(ingest_fail)
      end

      it 'returns solr error status if non-xml doc does not ingest correctly' do
        allow(harvester).to receive('doc_valid?').and_return(true)

        expect(harvester.insert_solr_doc('bad_doc', SearchSolrTools::Harvesters::Base::JSON_CONTENT_TYPE)).to eql(ingest_fail)
      end

      it 'returns OK status if valid xml doc ingests correctly' do
        allow(harvester).to receive('doc_valid?').and_return(true)

        expect(harvester.insert_solr_doc('good_doc')).to eql(ingest_ok)
      end

      it 'returns OK status if valid non-xml doc ingests correctly' do
        allow(harvester).to receive('doc_valid?').and_return(true)

        expect(harvester.insert_solr_doc('good_doc', SearchSolrTools::Harvesters::Base::JSON_CONTENT_TYPE)).to eql(ingest_ok)
      end
    end
  end

  def get_response(found_count)
    "{'responseHeader'=>{'status'=>0,'QTime'=>7,'params'=>{'q'=>'data_centers:\"test\"','wt'=>'ruby','rows'=>'0'}},'response'=>{'numFound'=>#{found_count},'start'=>0,'docs'=>[]}}"
  end

  def stub_update_and_delete(all_count, not_updated_count)
    all_response = get_response(all_count)
    updated_response = get_response(not_updated_count)

    stub_request(:get, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/select?q=data_centers:%22test%22&rows=0&wt=ruby')
      .to_return(status: 200, body: all_response, headers: {})
    stub_request(:get, %r{http:\/\/integration.search-solr.apps.int.nsidc.org:8983\/solr\/nsidc_oai\/select\?q=last_update:.*AND%20data_centers:%22test%22&rows=0&wt=ruby})
      .to_return(status: 200, body: updated_response, headers: {})
    delete_stub = stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?wt=json')
                      .with(body:    /{\"delete\":{\"query\":\"last_update:.* AND data_centers:\\\"test\\\"\"}}/,
                            headers: { 'Content-Type' => 'application/json' })
                      .to_return(status: 200, body: '', headers: {})
    commit_stub = stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?wt=json')
                      .with(body:    /{\"commit\":{}/,
                            headers: { 'Content-Type' => 'application/json' })
                      .to_return(status: 200, body: '', headers: {})

    { delete_stub: delete_stub, commit_stub: commit_stub }
  end

  describe '#valid_solr_spatial_coverage?' do
    def described_method_valid(north: nil, east: nil, south: nil, west: nil)
      @harvester.valid_solr_spatial_coverage?([north, east, south, west])
    end

    before :each do
      @harvester = described_class.new
    end

    describe 'non-polar points' do
      it 'returns true for a random point' do
        expect(described_method_valid(north: 4, east: 4, south: 4, west: 4)).to eql(true)
      end

      it 'returns true for a line running east-west' do
        expect(described_method_valid(north: 0, east: 5, south: 0, west: 0)).to eql(true)
      end

      it 'returns true for a line running north-south' do
        expect(described_method_valid(north: 5, east: 0, south: 0, west: 0)).to eql(true)
      end

      it 'returns true for a normal bounding box' do
        expect(described_method_valid(north: 5, east: 5, south: 0, west: 0)).to eql(true)
      end
    end

    describe 'the north pole' do
      it 'returns true if east and west are equal' do
        expect(described_method_valid(north: 90, east: 45, south: 90, west: 45)).to eql(true)
      end

      it 'returns false if east and west are not equal' do
        expect(described_method_valid(north: 90, east: -45, south: 90, west: 45)).to eql(false)
      end
    end

    describe 'the south pole' do
      it 'returns true if east and west are equal' do
        expect(described_method_valid(north: -90, east: 45, south: -90, west: 45)).to eql(true)
      end

      it 'returns false if east and west are not equal' do
        expect(described_method_valid(north: -90, east: -45, south: -90, west: 45)).to eql(false)
      end
    end
  end
end
