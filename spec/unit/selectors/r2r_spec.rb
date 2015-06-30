require 'spec_helper'

describe SearchSolrTools::Selectors::R2R do
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/r2r.xml')
  iso_to_solr = SearchSolrTools::Helpers::IsoToSolr.new(:r2r)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: 'AE1319'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'AE1319'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: "Biological Controls on the Ocean's C:N:P Ratio"
    },
    {
      title: 'should grab the correct data_centers',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'Rolling Deck to Repository'
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords'][1]",
      expected_text: 'EARTH SCIENCE > Oceans'
    },
    {
      title: 'should grab the correct dataset_url link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://linked.rvdata.us/resource/cruise/AE1319'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2015-06-28T03:11:52Z'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages'][1]",
      expected_text: '31.63968 -70.24632 55.00906 -39.98639'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial'][1]",
      expected_text: '-70.24632 31.63968 -39.98639 55.00906'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area']",
      expected_text: '23.36938'
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages'][1]",
      expected_text: '2013-08-14,2013-09-11'
    },
    {
      title: 'should grab the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: '29'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal'][1]",
      expected_text: '20.130814 20.130911'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct spatial scope facet',
      xpath: "/doc/field[@name='facet_spatial_scope'][1]",
      expected_text: 'Between 1 and 170 degrees of latitude change | Regional'
    },
    {
      title: 'should grab the correct facet_temporal_duration',
      xpath: "/doc/field[@name='facet_temporal_duration'][1]",
      expected_text: '< 1 year'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      expect(solr_doc.xpath(expectation[:xpath]).text.strip).to eql expectation[:expected_text]
    end
  end
end
