require 'ade_harvester'
require 'webmock/rspec'
require 'ade_csw_iso_query_builder'

describe ADEHarvester do
  describe 'Harvest process' do
    before(:each) do
      @ade_harvester = ADEHarvester.new('integration')
      @ade_harvester.page_size = 25
    end

    describe 'Running CSW/ISO Queries against ACADIS GI-Cat' do
      it 'Builds a default request to query the ACADIS GI-Cat CSW/ISO service' do
        expect(@ade_harvester.build_csw_request).to eql('http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd')
      end

      it 'Builds a request to get the number of records from the ACADIS GI-Cat CSW/ISO service' do
        query_string = @ade_harvester.build_csw_request('hits', '1', '1')

        expect(query_string).to eql('http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=hits&outputFormat=application/xml&maxRecords=1&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd')
      end

    end

    describe 'Retrieving the records from GI-Cat' do
      it 'Builds a request to query the data from the ACADIS GI-Cat CSW/ISO service' do
        expected_query = 'http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd'
        actual_query = @ade_harvester.build_csw_request('results', '25', '1')

        expect(actual_query).to eql(expected_query)
      end

      it 'Makes a request to the GI-Cat CSW/ISO service' do
        csw_iso_url = 'http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso'
        query_params = ADECswIsoQueryBuilder.query_params({
          'resultType' => 'results',
          'maxRecords' => '25',
          'startPosition' => '1'
        })

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
        stub_request(:get, 'http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?ElementSetName=full&TypeNames=gmd:MD_Metadata&maxRecords=25&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&outputFormat=application/xml&outputSchema=http://www.isotc211.org/2005/gmd&request=GetRecords&resultType=results&service=CSW&startPosition=1&version=2.0.2')
          .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
          .to_return(status: 200, body: File.open('spec/fixtures/cisl_iso.xml'), headers: {})

        # the stubbed request for page 2 of results gets none back
        stub_request(:get, 'http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?ElementSetName=full&TypeNames=gmd:MD_Metadata&maxRecords=25&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&outputFormat=application/xml&outputSchema=http://www.isotc211.org/2005/gmd&request=GetRecords&resultType=results&service=CSW&startPosition=26&version=2.0.2')
          .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
          .to_return(status: 200, body: '', headers: {})

        nokogiri_doc = @ade_harvester.get_doc_with_translated_entries_from_gi_cat

        expect(nokogiri_doc.root.first_element_child.name).to eql('doc')
      end

      it 'Issues a request to update Solr with data' do
        stub_request(:post, 'http://liquid.colorado.edu:9283/solr/update?commit=true')
          .with(body: '<add><foo></add>',
                headers: {
                  'Accept' => '*/*; q=0.5, application/xml',
                  'Accept-Encoding' => 'gzip, deflate',
                  'Content-Length' => '16',
                  'Content-Type' => 'text/xml; charset=utf-8',
                  'User-Agent' => 'Ruby' })
          .to_return(status: 200, body: 'success', headers: {})

        response = @ade_harvester.insert_solr_docs '<add><foo></add>'

        expect(response).to eql('success')
      end

    end
  end
end
