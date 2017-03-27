require 'spec_helper'

describe 'CISL ISO to Solr converter' do
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/cisl_data_one.xml')
  iso_to_solr = SearchSolrTools::Helpers::IsoToSolr.new(:cisl)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'GEORGES Vegetation Survey, Data from the Atlas of NSW database: VIS flora survey module'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: "Georges River Vegetation Survey 1999. The GEORGES(Georges" \
      " River Vegetation Survey 1999) Survey is part of the Vegetation Information" \
      " System Survey Program of New South Wales which is a series of systematic" \
      " vegetation surveys conducted across the state between 1970 and the" \
      " present. Please use the following URL to access the dataset:" \
      " http://aekos.org.au/collection/nsw.gov.au/nsw_atlas/vis_flora_module/GEORGES"
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'Advanced Cooperative Arctic Data and Information Service'
    },
    {
      title: 'should grab the correct author',
      xpath: "/doc/field[@name='authors']",
      expected_text: ''
    },
    {
      title: 'should grab the correct keywords',
      xpath: "/doc/field[@name='keywords']",
      expected_text: 'FloraSpecies Presence/AbundanceVegetation StructureDisturbanceErosionGeologyLithologyLandscapeSoil'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2015-05-21T07:49:15Z'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'https://cn.dataone.org/cn/v2/resolve/aekos.org.au%2Fcollection%2Fnsw.gov.au%2Fnsw_atlas%2Fvis_flora_module%2FGEORGES.20150515'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages']",
      expected_text: '-34.241974 150.79623 -33.90228 151.15088'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: '150.79623 -34.241974 151.15088 -33.90228'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area']",
      expected_text: '0.3396940000000015'
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages']",
      expected_text: '1999-03-30T08:00:00Z,1999-06-29T07:00:00Z'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '19.990330 19.990629'
    },
    {
      title: 'should calculate the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: '91'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct data center facet',
      xpath: "/doc/field[@name='facet_data_center']",
      expected_text: 'Advanced Cooperative Arctic Data and Information Service | ACADIS Gateway'
    },
    {
      title: 'should grab the correct spatial scope facet',
      xpath: "/doc/field[@name='facet_spatial_scope']",
      expected_text: 'Less than 1 degree of latitude change | Local'
    },
    {
      title: 'should grab the correct temporal duration facet',
      xpath: "/doc/field[@name='facet_temporal_duration']",
      expected_text: '< 1 year'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      expect(solr_doc.xpath(expectation[:xpath]).text.strip).to eql expectation[:expected_text]
    end
  end
end
