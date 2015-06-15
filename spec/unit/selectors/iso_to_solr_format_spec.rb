require 'spec_helper'

describe 'ISO to SOLR format methods' do
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/nsidc_iso.xml')
  bad_fixture = Nokogiri.XML File.open('spec/unit/fixtures/nodc_iso_bad_spatial.xml')
  geo_node = fixture.xpath('.//gmd:EX_GeographicBoundingBox').first
  bad_geo_node = bad_fixture.xpath('.//gmd:EX_GeographicBoundingBox').first
  temporal_node = fixture.xpath('.//gmd:EX_TemporalExtent').first

  describe 'spatial' do
    it 'should generate a SWEN space separated string from a GeographicBoundingBox node' do
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.spatial_display_str(geo_node)).to eql '30.98 -180.0 90.0 180.0'
    end

    it 'should generate a WSEN space separated string from a GeographicBoundingBox node' do
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.spatial_index_str(geo_node)).to eql '-180.0 30.98 180.0 90.0'
    end

    it 'should calculate the correct spatial scope' do
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.get_spatial_scope_facet(geo_node)).to eql 'Between 1 and 170 degrees of latitude change | Regional'
    end
  end

  describe 'temporal' do
    it 'should generate a start/end date comma separated string from a TemporalExtent node' do
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.temporal_display_str(temporal_node)).to eql '1978-10-01,2011-12-31'
    end

    it 'should generate a stripped start/end date space separated string from a TemporalExtent node' do
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.temporal_index_str(temporal_node)).to eql '19.781001 20.111231'
    end

    it 'should calculate a duration in days from a TemporalExtent node' do
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.get_temporal_duration(temporal_node)).to eql 12_145
    end
  end

  describe 'facets' do
    it 'should set the spatial coverage(s) from a GeographicBoundingBox node' do
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.get_spatial_facet(geo_node)).to eql 'Non Global'
    end

    it 'should set the spatial coverage(s) to "No Spatial Information" when missing bounds' do
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.get_spatial_facet(bad_geo_node)).to be_nil
    end

    it 'should set the spatial scope to "No Spatial Information" when missing bounds' do
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.get_spatial_scope_facet(bad_geo_node)).to eql nil
    end

    it 'should set the duration(s) from a TemporalExtent node' do
      temporal_nodes = fixture.xpath('.//gmd:extent').first
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.get_temporal_duration_facet(temporal_nodes)).to eql ['1+ years', '5+ years', '10+ years']
    end

    it 'should set the organization short name and long name for the sponsored program' do
      node = fixture.xpath('.//gmd:pointOfContact/gmd:CI_ResponsibleParty[.//gmd:CI_RoleCode="custodian"]').first
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.sponsored_program_facet(node)).to eql 'NASA DAAC at the National Snow and Ice Data Center | NASA DAAC'
    end
  end

  describe 'dataset url' do
    it 'should preserve valid (absolute) URIs' do
      uri_node = fixture.xpath('.//gmd:CI_OnlineResource/gmd:linkage/gmd:URL').first
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.dataset_url(uri_node)).to eql uri_node.text.strip
    end

    it 'should replace invalid (relative) URIs with an empty string' do
      uri_node = bad_fixture.xpath('.//gmd:CI_OnlineResource/gmd:linkage/gmd:URL').first
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.dataset_url(uri_node)).to eql ''
    end
  end

  describe 'title' do
    it 'replaces "Not Available" from GI-Cat with "Dataset title not available' do
      title_node = bad_fixture.xpath('.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString').first
      expect(SearchSolrTools::Helpers::IsoToSolrFormat.title_format(title_node)).to eql 'Dataset title not available'
    end
  end
end
