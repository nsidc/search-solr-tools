require 'spec_helper'

describe 'USGS ISO to Solr converter' do
  fixture = Nokogiri.XML File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'usgs_iso.xml'))
  iso_to_solr = SearchSolrTools::Helpers::IsoToSolr.new(:usgs)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should include the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: '535ea29ae4b08e65d60fa705'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'Upper Klamath Basin Landsat Image for April 7, 2004: Path 44 Row 31'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'This subset of a Landsat-5 image shows part of the upper Klamath Basin. ' \
        'The original images were obtained from the U.S. Geological Survey Earth Resources'
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'U.S. Geological Survey ScienceBase'
    },
    {
      title: 'should grab the correct author',
      xpath: "/doc/field[@name='authors'][1]",
      expected_text: 'Daniel T. Snyder'
    },
    {
      title: 'should grab the correct keywords',
      xpath: "/doc/field[@name='keywords'][1]",
      expected_text: 'Upper Klamath Basin'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2014-07-05T03:04:32Z'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'https://www.sciencebase.gov/catalog/item/535ea29ae4b08e65d60fa705'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages'][1]",
      expected_text: '41.99176 -123.3826 43.492919 -120.601579'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial'][1]",
      expected_text: '-123.3826 41.99176 -120.601579 43.492919'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area'][1]",
      expected_text: '31.25'
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages'][1]",
      expected_text: '2004-04-07,2004-04-07'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal'][1]",
      expected_text: '20.040407 20.040407'
    },
    {
      title: 'should calculate the correct temporal durations, and choose the maximum duration from multiple temporal coverages',
      xpath: "/doc/field[@name='temporal_duration'][1]",
      expected_text: '365'
    },
    {
      title: 'should convert just a YYYY entry to the full range of the year, grabbing the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages'][2]",
      expected_text: '2003-01-01,2003-12-31'
    },
    {
      title: 'should convert just a YYYY entry to the full range of the year, grabbing the correct temporal range in spatial format',
      xpath: "/doc/field[@name='temporal'][2]",
      expected_text: '20.030101 20.031231'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct data center facet',
      xpath: "/doc/field[@name='facet_data_center']",
      expected_text: 'U.S. Geological Survey ScienceBase | USGS ScienceBase'
    },
    {
      title: 'should grab the correct spatial scope facet',
      xpath: "/doc/field[@name='facet_spatial_scope'][1]",
      expected_text: 'Between 1 and 170 degrees of latitude change | Regional'
    },
    {
      title: 'should grab the correct temporal duration facet',
      xpath: "/doc/field[@name='facet_temporal_duration'][1]",
      expected_text: '< 1 year'
    },
    {
      title: 'should grab the correct temporal duration facet from just a YYYY entry',
      xpath: "/doc/field[@name='facet_temporal_duration'][2]",
      expected_text: '1+ years'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      expect(solr_doc.xpath(expectation[:xpath]).text.strip).to eql expectation[:expected_text]
    end
  end
end
