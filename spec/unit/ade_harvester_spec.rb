require 'ade_harvester'
require 'webmock/rspec'
require 'selectors/helpers/csw_iso_query_builder'

describe ADEHarvester do
  describe 'Harvest process' do
    before(:each) do
      @ade_harvester = ADEHarvester.new('integration')
      @ade_harvester.page_size = 25
    end

    describe 'The harvester can enable a gi-cat profile before it starts the harvest' do
      it 'has the default profile enabled' do
        expect(@ade_harvester.profile).to eql 'CISL'
      end

      it 'can enable a different profile' do
        @ade_harvester = ADEHarvester.new('integration', 'EOL')
        expect(@ade_harvester.profile).to eql 'EOL'
      end
    end

    describe 'Running CSW/ISO Queries against ACADIS GI-Cat' do
      it 'Builds a default request to query the ACADIS GI-Cat CSW/ISO service' do
        expect(@ade_harvester.build_csw_request).to eql('http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)')
      end

      it 'Builds a request to get the number of records from the ACADIS GI-Cat CSW/ISO service' do
        query_string = @ade_harvester.build_csw_request('hits', '1', '1')

        expect(query_string).to eql('http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&ElementSetName=full&resultType=hits&outputFormat=application/xml&maxRecords=1&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)')
      end

    end

    describe 'Retrieving the records from GI-Cat' do
      it 'Builds a request to query the data from the ACADIS GI-Cat CSW/ISO service' do
        expected_query = 'http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)'
        actual_query = @ade_harvester.build_csw_request('results', '25', '1')

        expect(actual_query).to eql(expected_query)
      end

      it 'Makes a request to the GI-Cat CSW/ISO service' do
        csw_iso_url = 'http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso'
        query_params = CswIsoQueryBuilder.query_params(
          'namespace' => 'xmlns(gmd=http://www.isotc211.org/2005/gmd)',
          'resultType' => 'results',
          'maxRecords' => '25',
          'startPosition' => '1'
        )

        stub_request(:get, csw_iso_url).with(query: query_params)
        .to_return(status: 200, body: '<gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd"><foo/></gmd:MD_Metadata>')

        start_index = 1
        results = @ade_harvester.get_results_from_gi_cat(start_index)

        expect(results[0].first_element_child.to_xml).to eql('<foo/>')
      end
    end

    describe 'Adding documents to Solr' do

      it 'constructs an xml document with <doc> children' do
        # the stubbed request for page 1 of results gets the fixture back
        stub_request(:get, 'http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?ElementSetName=full&TypeNames=gmd:MD_Metadata&maxRecords=25&outputFormat=application/xml&outputSchema=http://www.isotc211.org/2005/gmd&request=GetRecords&resultType=results&service=CSW&startPosition=1&version=2.0.2&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)')
          .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
          .to_return(status: 200, body: File.open('spec/unit/fixtures/cisl_iso.xml'), headers: {})

        # the stubbed request for page 2 of results gets none back
        stub_request(:get, 'http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?ElementSetName=full&TypeNames=gmd:MD_Metadata&maxRecords=25&outputFormat=application/xml&outputSchema=http://www.isotc211.org/2005/gmd&request=GetRecords&resultType=results&service=CSW&startPosition=26&version=2.0.2&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)')
          .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
          .to_return(status: 200, body: '', headers: {})

        entries = @ade_harvester.get_results_from_gi_cat(1)

        nokogiri_docs = @ade_harvester.get_docs_with_translated_entries_from_gi_cat(entries)

        expect(nokogiri_docs.first.root.name).to eql('add')
        expect(nokogiri_docs.first.root.first_element_child.name).to eql('doc')
      end

      it 'Issues a request to update Solr with data' do
        stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/update?commit=true')
          .with(body: Nokogiri.XML('<add><foo></add>').to_xml,
                headers: {
                  'Accept' => '*/*; q=0.5, application/xml',
                  'Accept-Encoding' => 'gzip, deflate',
                  'Content-Length' => '44',
                  'Content-Type' => 'text/xml; charset=utf-8',
                  'User-Agent' => 'Ruby' })
          .to_return(status: 200, body: 'success', headers: {})

        response = @ade_harvester.insert_solr_doc Nokogiri.XML('<add><foo></add>')

        expect(response).to eql(true)
      end

    end
  end
end
