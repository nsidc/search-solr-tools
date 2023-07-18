# frozen_string_literal: true

require 'spec_helper'
load 'bin/search_solr_tools'

describe SolrHarvestCLI do
  before do
    @cli = described_class.new
    allow(@cli).to receive(:harvester_map).and_return('nsidc' => SearchSolrTools::Harvesters::NsidcJson)
  end

  describe '#get_harvester_class' do
    it 'returns the correct harvester class' do
      expect(@cli.get_harvester_class('nsidc')).to eql SearchSolrTools::Harvesters::NsidcJson
    end
  end

  describe '#ping' do
    before do
      @harvester_class = SearchSolrTools::Harvesters::NsidcJson
    end

    it 'returns successful ping message and code if solr and source are up' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(true)
      expect_any_instance_of(@harvester_class).to receive(:ping_solr)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(true)
      expect_any_instance_of(@harvester_class).to receive(:ping_source)

      @cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }
      expect { @cli.ping }.not_to raise_error
    end

    it 'returns error if solr is up but source is not' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(true)
      expect_any_instance_of(@harvester_class).to receive(:ping_solr)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(false)
      expect_any_instance_of(@harvester_class).to receive(:ping_source)

      @cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }
      expect { @cli.ping }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(SearchSolrTools::Errors::HarvestError::ERRCODE_SOURCE_PING)
      end
    end

    it 'returns error if source is up but solr is not' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(false)
      expect_any_instance_of(@harvester_class).to receive(:ping_solr)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(true)
      expect_any_instance_of(@harvester_class).to receive(:ping_source)

      @cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }
      expect { @cli.ping }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(SearchSolrTools::Errors::HarvestError::ERRCODE_SOLR_PING)
      end
    end

    it 'returns error if neither solr nor source are up' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(false)
      expect_any_instance_of(@harvester_class).to receive(:ping_solr)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(false)
      expect_any_instance_of(@harvester_class).to receive(:ping_source)

      @cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }
      expect { @cli.ping }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(SearchSolrTools::Errors::HarvestError::ERRCODE_SOLR_PING + SearchSolrTools::Errors::HarvestError::ERRCODE_SOURCE_PING)
      end
    end
  end

  describe '#harvest' do
    let(:ingest_ok) { SearchSolrTools::Helpers::HarvestStatus::INGEST_OK }
    let(:ingest_invalid_doc) { SearchSolrTools::Helpers::HarvestStatus::INGEST_ERR_INVALID_DOC }
    let(:ingest_solr_err) { SearchSolrTools::Helpers::HarvestStatus::INGEST_ERR_SOLR_ERROR }
    let(:doc_result) { { num_docs: 3, add_docs: %w[doc1 doc2 doc3], failure_ids: [] } }

    before do
      @harvester_class = SearchSolrTools::Harvesters::NsidcJson
    end

    it 'calls the selected harvester classes' do
      puts "CLI#{@cli.harvester_map}"
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:harvest_and_delete).and_return(true)
      expect_any_instance_of(@harvester_class).to receive(:harvest_and_delete)

      @cli.options = { data_center: %w[nsidc], die_on_failure: false, environment: 'dev' }
      @cli.harvest
    end

    it 'fails when an invalid datacenter is provided' do
      @cli.options = { data_center: ['not a real datacenter'], environment: 'dev' }
      expect { @cli.harvest }.to raise_exception(SystemExit) do |error|
        expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_OTHER)
      end
    end

    # TODO: Write a test that exercises the "die on failure" flag.  That flag is
    #  used in situations where the "ping" against the data center (ie, DCS)
    #  worked, but attempting to get a list of identifiers to be harvested times
    #  out or returns errors (as opposed to "successfully" returning an empty list).

    it 'fails when the attempt to get the identifiers times out' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:get_results).and_return(nil)

      @cli.options = { data_center: %w[nsidc], environment: 'dev' }
      expect { @cli.harvest }.to raise_error(SystemExit) do |error|
        expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_SOURCE_NO_RESULTS)
      end
    end

    it 'fails when the attempt to get the identifier list is empty' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:get_results).and_return([])

      @cli.options = { data_center: %w[nsidc], environment: 'dev' }
      expect { @cli.harvest }.to raise_error(SystemExit) do |error|
        expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_SOURCE_NO_RESULTS)
      end
    end

    it 'fails when an invalid document is detected before ingest' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:docs_with_translated_entries_from_nsidc).and_return(doc_result)
      allow_any_instance_of(@harvester_class).to receive(:insert_solr_doc).and_return(ingest_ok, ingest_invalid_doc, ingest_ok)

      @cli.options = { data_center: %w[nsidc], environment: 'integration' }
      expect { @cli.harvest }.to raise_error(SystemExit) do |error|
        expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_DOCUMENT_INVALID)
      end
    end

    it 'fails when there is an error ingesting into solr' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:docs_with_translated_entries_from_nsidc).and_return(doc_result)
      allow_any_instance_of(@harvester_class).to receive(:insert_solr_doc).and_return(ingest_ok, ingest_solr_err, ingest_ok)

      @cli.options = { data_center: %w[nsidc], environment: 'integration' }
      expect { @cli.harvest }.to raise_error(SystemExit) do |error|
        expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_INGEST_ERROR)
      end
    end

    it 'fails when there is an invalid document and ingest errors' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:docs_with_translated_entries_from_nsidc).and_return(doc_result)
      allow_any_instance_of(@harvester_class).to receive(:insert_solr_doc).and_return(ingest_solr_err, ingest_invalid_doc, ingest_ok)

      @cli.options = { data_center: %w[nsidc], environment: 'integration' }
      expect { @cli.harvest }.to raise_error(SystemExit) do |error|
        expect(error.status).to eql(SearchSolrTools::Errors::HarvestError::ERRCODE_INGEST_ERROR +
                                    SearchSolrTools::Errors::HarvestError::ERRCODE_DOCUMENT_INVALID)
      end
    end

    it 'does not fail when documents are found and all ingest properly' do
      allow_any_instance_of(@harvester_class).to receive(:ping_solr).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:ping_source).and_return(true)
      allow_any_instance_of(@harvester_class).to receive(:docs_with_translated_entries_from_nsidc).and_return(doc_result)
      allow_any_instance_of(@harvester_class).to receive(:insert_solr_doc).and_return(ingest_ok)

      @cli.options = { data_center: %w[nsidc], environment: 'integration' }
      expect { @cli.harvest }.not_to raise_error(SystemExit)
    end
  end

  describe '#delete_by_data_center' do
    it 'calls delete_old_documents on the correct class' do
      @cli.options = { timestamp: '2014-07-14T21:49:21Z', environment: 'dev', data_center: 'nsidc' }
      allow_any_instance_of(SearchSolrTools::Harvesters::NsidcJson).to receive(:delete_old_documents).and_return(true)
      expect_any_instance_of(SearchSolrTools::Harvesters::NsidcJson).to receive(:delete_old_documents).with(
        '2014-07-14T21:49:21Z',
        'data_centers:"National Snow and Ice Data Center"',
        'nsidc_oai',
        true
      )
      @cli.delete_by_data_center
    end
  end
end
