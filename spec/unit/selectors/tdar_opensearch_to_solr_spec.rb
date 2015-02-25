require 'selectors/helpers/iso_to_solr'
require 'selectors/helpers/iso_namespaces'

describe 'TDAR to Solr converter' do

  puts "\n\n-----------\n"
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/tdar_opensearch.xml')
  fixture = fixture.at_xpath('.//atom:entry', IsoNamespaces.namespaces(fixture))
  iso_to_solr = IsoToSolr.new(:tdar)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
   {
      title: 'should grab the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: 'TDAR-370044'
   },
   {
     title: 'should grab the correct title',
     xpath: "/doc/field[@name='title']",
     expected_text: '4E Survey Catalog'
   },
   {
     title: 'should grab the correct summary',
     xpath: "/doc/field[@name='summary']",
     expected_text: 'This is an inventory of artifacts collected during the 4E survey.'
   },
   {
     title: 'should grab the correct data_centers',
     xpath: "/doc/field[@name='data_centers']",
     expected_text: 'Digital Archaeological Record'
   },
   {
     title: 'should include the correct keywords',
     xpath: "/doc/field[@name='keywords']",
     expected_text: ''
   },
   {
     title: 'should grab the correct dataset_url link',
     xpath: "/doc/field[@name='dataset_url']",
     expected_text: 'http://core.tdar.org/dataset/370044/4e-survey-catalog'
   },
   {
     title: 'should grab the correct updated date',
     xpath: "/doc/field[@name='last_revision_date']",
     expected_text: '2011-10-27T18:07:53Z'
   },
   {
     title: 'should grab the correct spatial display bounds',
     xpath: "/doc/field[@name='spatial_coverages'][1]",
     expected_text: '-74.85706 43.01543 -74.85706 43.01543'
   },
   {
     title: 'should grab the correct spatial bounds',
     xpath: "/doc/field[@name='spatial'][1]",
     expected_text: '43.01543 -74.85706 43.01543 -74.85706'
   },
   {
     title: 'should calculate the correct spatial area',
     xpath: "/doc/field[@name='spatial_area'][1]",
     expected_text: '0.0'
   },
   {
    title: 'should grab the correct temporal coverage',
    xpath: "/doc/field[@name='temporal_coverages'][1]",
    expected_text: '2011-10-27T18:07:53Z,2011-10-27T18:07:53Z'
   },
   {
     title: 'should grab the correct temporal duration',
     xpath: "/doc/field[@name='temporal_duration'][1]",
     expected_text: '1'
   },
   {
     title: 'should grab the correct temporal range',
     xpath: "/doc/field[@name='temporal'][1]",
     expected_text: '20.111027 20.111027'
   },
   {
     title: 'should grab the correct source',
     xpath: "/doc/field[@name='source']",
     expected_text: 'ADE'
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
