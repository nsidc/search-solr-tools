require 'spec_helper'

describe 'NODC ISO with Bad Spatial Bounds to Solr converter' do
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/nodc_iso_bad_spatial.xml')
  iso_to_solr = SearchSolrTools::Helpers::IsoToSolr.new(:nodc)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: 'gov.noaa.nodc:0001497'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'Not Available'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: ''
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'NOAA National Oceanographic Data Center'
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords']",
      expected_text: 'oceanography'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2013-06-03T00:00:00Z'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      # NOTE: I'm grabbing the FTP link explicitly.  NODC has really good data
      # access links with other representations available.
      expected_text: 'ftp://ftp.nodc.noaa.gov/nodc/archive/arc0016/0001497/'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: '60.0 90.0'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area']",
      expected_text: '30.0'
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages']",
      expected_text: '1985-04-13T00:00:00Z,1994-11-23T00:00:00Z'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '19.850413 19.941123'
    },
    {
      title: 'should grab the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: '3512'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct data center facet',
      xpath: "/doc/field[@name='facet_data_center']",
      expected_text: 'NOAA National Oceanographic Data Center | NOAA NODC'
    },
    {
      title: 'should grab the correct spatial scope facet',
      xpath: "/doc/field[@name='facet_spatial_scope']",
      expected_text: ''
    },
    {
      title: 'should grab the correct temporal duration facet',
      xpath: "/doc/field[@name='facet_temporal_duration']",
      expected_text: '1+ years5+ years'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      expect(solr_doc.xpath(expectation[:xpath]).text.strip).to eql expectation[:expected_text]
    end
  end
end
