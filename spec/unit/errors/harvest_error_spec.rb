require 'spec_helper'
require 'search_solr_tools/errors/harvest_error'

describe SearchSolrTools::Errors::HarvestError do
  let (:status) { SearchSolrTools::Helpers::HarvestStatus.new }

  it 'with Solr Ping error reports only that issue' do
    status.ping_solr = false

    err = described_class.new(status)
    expect(err.exit_code).to eql(described_class::ERRCODE_SOLR_PING)
  end

  it 'with Source Ping error reports only that issue' do
    status.ping_source = false

    err = described_class.new(status)
    expect(err.exit_code).to eql(described_class::ERRCODE_SOURCE_PING)
  end

  it 'with Solr and Source Ping error reports only those issues' do
    status.ping_solr = false
    status.ping_source = false

    err = described_class.new(status)
    expect(err.exit_code).to eql(described_class::ERRCODE_SOLR_PING + described_class::ERRCODE_SOURCE_PING)
  end

  it 'with No Results error reports only that issue' do
    status.record_document_status('doc', SearchSolrTools::Helpers::HarvestStatus::HARVEST_NO_DOCS)

    err = described_class.new(status)
    expect(err.exit_code).to eql(described_class::ERRCODE_SOURCE_NO_RESULTS)
  end

  it 'with Harvest, Invalid Document, and Ingest errors reports all those issues' do
    status.record_document_status('doc2', SearchSolrTools::Helpers::HarvestStatus::HARVEST_FAILURE)
    status.record_document_status('doc3', SearchSolrTools::Helpers::HarvestStatus::INGEST_ERR_INVALID_DOC)
    status.record_document_status('doc3', SearchSolrTools::Helpers::HarvestStatus::INGEST_ERR_SOLR_ERROR)

    err = described_class.new(status)
    expect(err.exit_code).to eql(described_class::ERRCODE_SOURCE_HARVEST_ERROR +
                                 described_class::ERRCODE_DOCUMENT_INVALID +
                                 described_class::ERRCODE_INGEST_ERROR)
  end
end