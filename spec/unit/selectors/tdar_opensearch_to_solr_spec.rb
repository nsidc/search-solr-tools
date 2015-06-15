require 'spec_helper'

describe 'TDAR to Solr converter' do
  puts "\n\n-----------\n"
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/tdar_opensearch.xml')
  fixture = fixture.at_xpath('.//atom:entry', SearchSolrTools::Helpers::IsoNamespaces.namespaces(fixture))
  iso_to_solr = SearchSolrTools::Helpers::IsoToSolr.new(:tdar)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: 'TDAR-398502'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'Dismal River ceramic sherd data'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'These are the results from an analysis of ceramics from 43 Dismal River sites.'
    },
    {
      title: 'should grab the correct data_centers',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'tDAR: The Digital Archaeological Record'
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords']",
      expected_text: ''
    },
    {
      title: 'should grab the correct dataset_url link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://core.tdar.org/dataset/398502/dismal-river-ceramic-sherd-data'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2015-04-29T17:53:58Z'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages'][1]",
      expected_text: '36.663719013583545 -111.29150390625 45.548422106917535 -93.97705078125'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial'][1]",
      expected_text: '-111.29150390625 36.663719013583545 -93.97705078125 45.548422106917535'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area'][1]",
      expected_text: '0.0'
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages'][1]",
      expected_text: ''
    },
    {
      title: 'should grab the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration'][1]",
      expected_text: ''
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal'][1]",
      expected_text: ''
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    }, {
      title: 'should grab the correct data center facet',
      xpath: "/doc/field[@name='facet_data_center']",
      expected_text: 'tDAR: The Digital Archaeological Record | tDAR'
    }, {
      title: 'should grab the correct spatial scope facet',
      xpath: "/doc/field[@name='facet_spatial_scope'][1]",
      expected_text: 'Between 1 and 170 degrees of latitude change | Regional'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      expect(solr_doc.xpath(expectation[:xpath]).text.strip).to eql expectation[:expected_text]
    end
  end
  puts "\n\n==============\n"
end
