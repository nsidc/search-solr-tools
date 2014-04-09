require 'nokogiri'
require './lib/selectors/solr_string_format'

describe 'SOLR format methods' do
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/nsidc_iso.xml')
  bad_fixture = Nokogiri.XML File.open('spec/unit/fixtures/nodc_iso_bad_spatial.xml')
  geo_node = fixture.xpath('.//gmd:EX_GeographicBoundingBox').first
  bad_geo_node = bad_fixture.xpath('.//gmd:EX_GeographicBoundingBox').first
  temporal_node = fixture.xpath('.//gmd:EX_TemporalExtent').first


  describe 'date' do
    it 'should generate a SOLR readable ISO 8601 string using the DATE helper' do
      SolrStringFormat::DATE.call(fixture.xpath('.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date')).should eql '2004-05-10T00:00:00Z'
    end
  end

  describe 'date' do
    it 'should generate a SOLR readable ISO 8601 string from a date obect' do
      SolrStringFormat.date_str(DateTime.new(2013, 1, 1)).should eql '2013-01-01T00:00:00Z'
    end

    it 'should generate a SOLR readable ISO 8601 string from a string' do
      SolrStringFormat.date_str('2013-01-01').should eql '2013-01-01T00:00:00Z'
    end

    it 'should generate a SOLR readable ISO 8601 string string with extra spaces' do
      SolrStringFormat.date_str('    2013-01-01 ').should eql '2013-01-01T00:00:00Z'
    end
  end

  describe 'temporal' do
    it 'should use only the maximum duration when a dataset has multiple temporal ranges' do
      durations = [27, 123, 325, 234, 19_032, 3]
      SolrStringFormat.reduce_temporal_duration(durations).should eql 19_032
    end
  end

  describe 'facets' do
    it 'should set the parameter for a variable level_1' do
      node = fixture.xpath('.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="discipline"]//gmd:keyword/gco:CharacterString')[0].text
      SolrStringFormat.parameter_binning(node).should eql 'Ice Extent'
    end

    it 'should bin the parameter' do
      node = fixture.xpath('.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="discipline"]//gmd:keyword/gco:CharacterString')[1].text
      SolrStringFormat.parameter_binning(node).should eql 'Ocean Properties (other)'
    end

    it 'should not set parameters that do not have variable level_1' do
      node = fixture.xpath('.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="discipline"]//gmd:keyword/gco:CharacterString')[2].text
      SolrStringFormat.parameter_binning(node).should eql nil
    end

    it 'should set the data format' do
      node = fixture.xpath('.//gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString')[0].text
      SolrStringFormat.format_binning(node).should eql 'HTML'
    end

    it 'should bin the data format' do
      node = fixture.xpath('.//gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString')[1].text
      SolrStringFormat.format_binning(node).should eql 'ASCII Text'
    end

    it 'should not set excluded data formats' do
      node = fixture.xpath('.//gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString')[2].text
      SolrStringFormat.format_binning(node).should eql nil
    end
  end


end