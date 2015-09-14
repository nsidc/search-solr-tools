require 'spec_helper'

describe SearchSolrTools::Helpers::CswIsoQueryBuilder do
  describe 'get_query_string returns CSW/ISO query URLs' do
    it 'Returns a URL with default query parameters when invoked without arguments' do
      query = described_class.get_query_string 'http://fakeurl.org/csw'
      expect(query).to eq 'http://fakeurl.org/csw?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd'
    end

    it 'Returns a URL with a result type of "hits"' do
      query = described_class.get_query_string('http://fakeurl.org/csw', 'resultType' => 'hits')
      expect(query).to eq 'http://fakeurl.org/csw?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&ElementSetName=full&resultType=hits&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd'
    end
  end
end
