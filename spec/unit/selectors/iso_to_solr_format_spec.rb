require 'nokogiri'
require './lib/selectors/iso_to_solr_format'

describe 'ISO to SOLR format methods' do
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/nsidc_iso.xml')
  geo_node = fixture.xpath('.//gmd:EX_GeographicBoundingBox').first
  temporal_node = fixture.xpath('.//gmd:EX_TemporalExtent').first

  describe 'date' do
    it 'should generate a SOLR readable ISO 8601 string from a date obect' do
      IsoToSolrFormat.date_str(DateTime.new(2013, 1, 1)).should eql '2013-01-01T00:00:00Z'
    end

    it 'should generate a SOLR readable ISO 8601 string from a string' do
      IsoToSolrFormat.date_str('2013-01-01').should eql '2013-01-01T00:00:00Z'
    end

    it 'should generate a SOLR readable ISO 8601 string string with extra spaces' do
      IsoToSolrFormat.date_str('    2013-01-01 ').should eql '2013-01-01T00:00:00Z'
    end

    it 'should generate a SOLR readable ISO 8601 string using the DATE helper' do
      IsoToSolrFormat::DATE.call(fixture.xpath('.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date')).should eql '2004-05-10T00:00:00Z'
    end
  end

  describe 'temporal duration' do
    it 'should calculate a correct duration for a single date range' do
      temporal_node = fixture.xpath('.//gmd:extent').first
      expect(IsoToSolrFormat.facet_temporal_duration(temporal_node)).to eql '10+ years'
    end
  end

  describe 'spatial' do
    it 'should generate a SWEN space separated string from a GeographicBoundingBox node' do
      IsoToSolrFormat.spatial_display_str(geo_node).should eql '30.98 -180 90 180'
    end

    it 'should generate a WSEN space separated string from a GeographicBoundingBox node' do
      IsoToSolrFormat.spatial_index_str(geo_node).should eql '-180 30.98 180 90'
    end
  end

  describe 'temporal' do
    it 'should generate a start/end date comma separated string from a TemporalExtent node' do
      IsoToSolrFormat.temporal_display_str(temporal_node).should eql '1978-10-01,2011-12-31'
    end

    it 'should generate a striped start/end date space separated string from a TemporalExtent node' do
      IsoToSolrFormat.temporal_index_str(temporal_node).should eql '19.781001 20.111231'
    end
  end

  describe 'facets' do
    it 'should set the spatial coverage(s) from a GeographicBoundingBox node' do
      IsoToSolrFormat.get_spatial_facet(geo_node).should eql 'Northern Hemisphere'
    end

    it 'should set the duration(s) from a TemporalExtent node' do
      temporal_nodes = fixture.xpath('.//gmd:extent').first
      IsoToSolrFormat.facet_temporal_duration(temporal_nodes).should eql '10+ years'
    end
  end
end
