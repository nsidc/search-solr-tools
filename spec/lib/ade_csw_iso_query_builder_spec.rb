require 'ade_csw_iso_query_builder'

describe ADECswIsoQueryBuilder do

  describe "get_query_string returns CSW/ISO query URLs" do
    it "Returns a URL with default query parameters when invoked without arguments" do
      query = ADECswIsoQueryBuilder::get_query_string()
      query.should eq "?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd"
    end

    it "Returns a URL with a result type of 'hits'" do
      query = ADECswIsoQueryBuilder::get_query_string( :resultType => "hits" )
      query.should eq "?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=hits&outputFormat=application/xml&maxRecords=25&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd"
    end
  end
end
