require "ade_harvester"
require 'webmock/rspec'
require 'ade_csw_iso_query_builder'

describe ADEHarvester do

  describe "Initialization" do
    it "Uses a default environment if not specified" do
      ade_harvester = ADEHarvester.new
      expect(ade_harvester.environment).to eq("development")
    end

    it "Initializes with a specific environment name" do
      ade_harvester = ADEHarvester.new("qa")
      expect(ade_harvester.environment).to eq("qa")
    end
  end

  describe "Harvest process" do
    before(:each) do
      @ade_harvester = ADEHarvester.new("integration");
    end

    describe "Running CSW/ISO Queries against ACADIS GI-Cat" do
      it "Builds a default request to query the ACADIS GI-Cat CSW/ISO service" do
        expect(@ade_harvester.buildCswRequest).to eql("http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd")
      end

      it "Builds a request to get the number of records from the ACADIS GI-Cat CSW/ISO service" do
        queryString = @ade_harvester.buildCswRequest("hits", "1", "1")

        expect(queryString).to eql("http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=hits&outputFormat=application/xml&maxRecords=1&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd")
      end

      it "Requests the number of records in the CSW/ISO response" do
        csw_iso_url = "http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso"
        query_params = ADECswIsoQueryBuilder::query_params({
          :resultType => "hits",
          :maxRecords => "1",
          :startPosition => "1"
        })

        stub_request(:get, csw_iso_url).with(:query => query_params)
        .to_return(:status => 200, :body => File.new("spec/fixtures/results_count.xml"))

        expect(@ade_harvester.getNumberOfRecords).to eql(10)
      end
    end

    describe "Retrieving the records from GI-Cat" do
      it "Builds a request to query the data from the ACADIS GI-Cat CSW/ISO service" do
        expectedQuery = "http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd"
        actualQuery = @ade_harvester.buildCswRequest("results", "25", "1")

        expect(actualQuery).to eql(expectedQuery)
      end

      it "Makes a request to the GI-Cat CSW/ISO service" do
        csw_iso_url = "http://liquid.colorado.edu:11380/api/gi-cat/services/cswiso"
        query_params = ADECswIsoQueryBuilder::query_params({
          :resultType => "results",
          :maxRecords => "25",
          :startPosition => "1"
        })

        stub_request(:get, csw_iso_url).with(:query => query_params)
        .to_return(:status => 200, :body => "<foo/>")

        responseXml = @ade_harvester.getResults 25, 1

        expect(responseXml.xpath('foo').first().name()).to eql("foo")
      end

    end

    describe "Adding documents to Solr" do
      it "Creates an XML message to add documents in Solr" do
        xmlDoc = "<root><doc>a</doc><doc><foo></doc></root>"
        docs = Nokogiri::XML("<add>" + xmlDoc + "</add>")
        expect(@ade_harvester.buildAddXMLMessage(xmlDoc)).to eql(docs.to_xml)
      end

      it "Issues a request to update Solr with data" do
        stub_request(:post, "http://liquid.colorado.edu:9283/solr/update?commit=true")
          .with(:body => "<add><foo></add>",
               :headers => {'Accept'=>'*/*; q=0.5, application/xml',
                            'Accept-Encoding'=>'gzip, deflate',
                            'Content-Length'=>'16',
                            'Content-Type'=>'text/xml; charset=utf-8',
                            'User-Agent'=>'Ruby'})
          .to_return(:status => 200, :body => "success", :headers => {})

        response = @ade_harvester.insertSolrDocs "<add><foo></add>"

        expect(response).to eql(200)
      end

    end
  end
end

