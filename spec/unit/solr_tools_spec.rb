# frozen_string_literal: true

require 'spec_helper'
load 'bin/search_solr_tools'

describe SolrHarvestCLI do
  let(:cli) { described_class.new }

  before do
    allow(cli).to receive(:harvester_map).and_return('nsidc' => SearchSolrTools::Harvesters::NsidcJson)
  end

  describe '#get_harvester_class' do
    it 'returns the correct harvester class' do
      expect(cli.get_harvester_class('nsidc')).to eql SearchSolrTools::Harvesters::NsidcJson
    end
  end

  describe '#ping' do
    let(:harvester_class) { SearchSolrTools::Harvesters::NsidcJson }
    let(:harvester_instance) { instance_double(harvester_class) }

    before do
      allow(harvester_class).to receive(:new).and_return(harvester_instance)
    end

    it 'returns successful ping message and code if solr and source are up' do
      allow(harvester_instance).to receive(:ping_solr).and_return(true)
      allow(harvester_instance).to receive(:ping_source).and_return(true)

      cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }

      expect { cli.ping }.not_to raise_error

      expect(harvester_instance).to have_received(:ping_solr)
      expect(harvester_instance).to have_received(:ping_source)
    end

    it 'returns error if solr is up but source is not' do
      allow(harvester_instance).to receive(:ping_solr).and_return(true)
      allow(harvester_instance).to receive(:ping_source).and_return(false)

      cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }
      expect { cli.ping }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(SearchSolrTools::Errors::HarvestError::ERRCODE_SOURCE_PING)
      end

      expect(harvester_instance).to have_received(:ping_solr)
      expect(harvester_instance).to have_received(:ping_source)
    end

    it 'returns error if source is up but solr is not' do
      allow(harvester_instance).to receive(:ping_solr).and_return(false)
      allow(harvester_instance).to receive(:ping_source).and_return(true)

      cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }
      expect { cli.ping }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(SearchSolrTools::Errors::HarvestError::ERRCODE_SOLR_PING)
      end

      expect(harvester_instance).to have_received(:ping_solr)
      expect(harvester_instance).to have_received(:ping_source)
    end

    it 'returns error if neither solr nor source are up' do
      allow(harvester_instance).to receive(:ping_solr).and_return(false)
      allow(harvester_instance).to receive(:ping_source).and_return(false)

      cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }
      expect { cli.ping }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(SearchSolrTools::Errors::HarvestError::ERRCODE_SOLR_PING + SearchSolrTools::Errors::HarvestError::ERRCODE_SOURCE_PING)
      end

      expect(harvester_instance).to have_received(:ping_solr)
      expect(harvester_instance).to have_received(:ping_source)
    end
  end

  describe '#harvest' do
    let(:ingest_ok) { SearchSolrTools::Helpers::HarvestStatus::INGEST_OK }
    let(:ingest_invalid_doc) { SearchSolrTools::Helpers::HarvestStatus::INGEST_ERR_INVALID_DOC }
    let(:ingest_solr_err) { SearchSolrTools::Helpers::HarvestStatus::INGEST_ERR_SOLR_ERROR }
    let(:doc_result) { { num_docs: 3, add_docs: %w[doc1 doc2 doc3], failure_ids: [] } }
    let(:harvester_class) { SearchSolrTools::Harvesters::NsidcJson }

    describe 'dev' do
      let(:harvester_instance) { harvester_class.new('dev') }

      before do
        allow(harvester_class).to receive(:new).and_return(harvester_instance)
      end

      it 'calls the selected harvester classes' do
        puts "CLI#{cli.harvester_map}"
        allow(harvester_instance).to receive(:ping_solr).and_return(true)
        allow(harvester_instance).to receive(:ping_source).and_return(true)
        allow(harvester_instance).to receive(:harvest_and_delete).and_return(true)

        cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }
        cli.harvest

        expect(harvester_instance).to have_received(:harvest_and_delete)
      end

      it 'fails when an invalid datacenter is provided' do
        cli.options = { data_center: ['not a real datacenter'], environment: 'dev' }
        expect { cli.harvest }.to raise_exception(SystemExit) do |error|
          expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_OTHER)
        end
      end

      # TODO: Write a test that exercises the "die on failure" flag.  That flag is
      #  used in situations where the "ping" against the data center (ie, DCS)
      #  worked, but attempting to get a list of identifiers to be harvested times
      #  out or returns errors (as opposed to "successfully" returning an empty list).

      it 'fails when the attempt to get the identifiers times out' do
        allow(harvester_instance).to receive(:ping_solr).and_return(true)
        allow(harvester_instance).to receive(:ping_source).and_return(true)
        allow(harvester_instance).to receive(:get_results).and_return(nil)

        cli.options = { data_center: %w[nsidc], environment: 'dev' }
        expect { cli.harvest }.to raise_error(SystemExit) do |error|
          expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_SOURCE_NO_RESULTS)
        end
      end

      it 'fails when the attempt to get the identifier list is empty' do
        allow(harvester_instance).to receive(:ping_solr).and_return(true)
        allow(harvester_instance).to receive(:ping_source).and_return(true)
        allow(harvester_instance).to receive(:get_results).and_return([])

        cli.options = { data_center: %w[nsidc], environment: 'dev' }
        expect { cli.harvest }.to raise_error(SystemExit) do |error|
          expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_SOURCE_NO_RESULTS)
        end
      end
    end

    describe 'integration' do
      let(:harvester_instance) { harvester_class.new('integration') }

      before do
        allow(harvester_class).to receive(:new).and_return(harvester_instance)
      end

      it 'fails when an invalid document is detected before ingest' do
        allow(harvester_instance).to receive(:ping_solr).and_return(true)
        allow(harvester_instance).to receive(:ping_source).and_return(true)
        allow(harvester_instance).to receive(:docs_with_translated_entries_from_nsidc).and_return(doc_result)
        allow(harvester_instance).to receive(:insert_solr_doc).and_return(ingest_ok, ingest_invalid_doc, ingest_ok)

        cli.options = { data_center: %w[nsidc], environment: 'integration' }
        expect { cli.harvest }.to raise_error(SystemExit) do |error|
          expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_DOCUMENT_INVALID)
        end
      end

      it 'fails when there is an error ingesting into solr' do
        allow(harvester_instance).to receive(:ping_solr).and_return(true)
        allow(harvester_instance).to receive(:ping_source).and_return(true)
        allow(harvester_instance).to receive(:docs_with_translated_entries_from_nsidc).and_return(doc_result)
        allow(harvester_instance).to receive(:insert_solr_doc).and_return(ingest_ok, ingest_solr_err, ingest_ok)

        cli.options = { data_center: %w[nsidc], environment: 'integration' }
        expect { cli.harvest }.to raise_error(SystemExit) do |error|
          expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_INGEST_ERROR)
        end
      end

      it 'fails when there is an invalid document and ingest errors' do
        allow(harvester_instance).to receive(:ping_solr).and_return(true)
        allow(harvester_instance).to receive(:ping_source).and_return(true)
        allow(harvester_instance).to receive(:docs_with_translated_entries_from_nsidc).and_return(doc_result)
        allow(harvester_instance).to receive(:insert_solr_doc).and_return(ingest_solr_err, ingest_invalid_doc, ingest_ok)

        cli.options = { data_center: %w[nsidc], environment: 'integration' }
        expect { cli.harvest }.to raise_error(SystemExit) do |error|
          expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_INGEST_ERROR +
                                      SearchSolrTools::Errors::HarvestError::ERRCODE_DOCUMENT_INVALID)
        end
      end

      it 'does not fail when documents are found and all ingest properly' do
        allow(harvester_instance).to receive(:ping_solr).and_return(true)
        allow(harvester_instance).to receive(:ping_source).and_return(true)
        allow(harvester_instance).to receive(:docs_with_translated_entries_from_nsidc).and_return(doc_result)
        allow(harvester_instance).to receive(:insert_solr_doc).and_return(ingest_ok)

        cli.options = { data_center: %w[nsidc], environment: 'integration' }
        expect { cli.harvest }.not_to raise_error(SystemExit)
      end
    end
  end

  describe '#delete_by_data_center' do
    let(:harvester_class) { SearchSolrTools::Harvesters::NsidcJson }
    let(:harvester_instance) { harvester_class.new('dev') }

    before do
      allow(harvester_class).to receive(:new).and_return(harvester_instance)
    end

    it 'calls delete_old_documents on the correct class' do
      cli.options = { timestamp: '2014-07-14T21:49:21Z', environment: 'dev', data_center: 'nsidc' }
      allow(harvester_instance).to receive(:delete_old_documents).and_return(true)

      cli.delete_by_data_center

      expect(harvester_instance).to have_received(:delete_old_documents).with(
        '2014-07-14T21:49:21Z',
        'data_centers:"National Snow and Ice Data Center"',
        'nsidc_oai',
        true
      )
    end
  end
end
