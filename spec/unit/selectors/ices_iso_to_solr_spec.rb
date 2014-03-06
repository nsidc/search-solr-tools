require 'iso_to_solr'

describe 'ICES ISO to Solr converter' do

  puts "\n\n-----------\n"
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/ices_iso.xml')
  iso_to_solr = IsoToSolr.new(:ices)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
   {
      title: 'should grab the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: 'b8ca014e-1bb8-4bda-8a8b-ba2b38e6eb4c'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'Marine biodiversity offshore'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'Under the MeshAtlantic project (2010-2013) the habitat of an area offshore'
    },
    {
      title: 'should grab the correct data_centers',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'International Council for the Exploration of the Sea (ICES)'
    },
    {
      title: 'should include the correct authors',
      xpath: "/doc/field[@name='authors']",
      expected_text: ''
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords'][1]",
      expected_text: 'Habitat, Biocenosis, Biotope, EUNIS'
    },
    {
      title: 'should grab the correct dataset_url link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://www.searchmesh.net/default.aspx?page=1974'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2013-08-15T00:00:00Z'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages'][1]",
      expected_text: '36.9783752976 -8.61173 37.03172 -8.45341'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial'][1]",
      expected_text: '-8.61173 36.9783752976 -8.45341 37.03172'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area']",
      expected_text: '1.0092799999999968'
    },
    {
     title: 'should grab the correct temporal coverage',
     xpath: "/doc/field[@name='temporal_coverages'][1]",
     expected_text: '2011-07-18T18:00:00Z,2012-02-10T10:00:00Z'
    },
    {
      title: 'should grab the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: '4018'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal'][1]",
      expected_text: '20.110718 20.120210'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct spatial facet',
      xpath: "/doc/field[@name='facet_spatial_coverage'][1]",
      expected_text: 'Non Global'
    },
    {
      title: 'should grab the correct spatial scope facet',
      xpath: "/doc/field[@name='facet_spatial_scope'][1]",
      expected_text: 'Less than 1 degree of latitude change | Local'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end
  puts "\n\n==============\n"
end
