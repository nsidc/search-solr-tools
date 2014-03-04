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
      expected_text: 'f0b16642-25cd-4b51-b15c-15769566aebe'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'Ribble survey'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'null'
    },
    {
      title: 'should grab the correct data_centers',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'International Council for the Exploration of the Sea (ICES)'
    },
    {
      title: 'should include the correct authors',
      xpath: "/doc/field[@name='authors']",
      expected_text: 'Entec, C.M. Howson, F. BunkerPosford Duvivier Environment'
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords']",
      expected_text: 'Habitats35E6; 36E6; 36E7Irish SeaHabitats44E2Minches & West ScotlandHabitats44E6Northern North SeaHabitats41E4Minches & West ScotlandHabitats44E1Scottish Continental ShelfHabitats45E4Minches & West ScotlandHabitats31F0; 31F1; 32F0; 32F1; 33F1; 34F0; 34F1Southern North SeaHabitats43E2; 44E2; 44E3; 45E2; 45E3Scottish Continental ShelfHabitats42E2; 43E2; 44E2; 44E3; 45E3Scottish Continental ShelfHabitats39E4; 41E4; 41E6; 41E7; 42E3; 43E3; 45E4Minches & West Scotland'
    },
    {
      title: 'should grab the correct dataset_url link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: ''
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '10007-03-01T00:00:00Z'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages'][1]",
      expected_text: '46 -26 64 7'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial'][1]",
      expected_text: '-26 46 7 64'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area']",
      expected_text: '180.0'
    },
    {
     title: 'should grab the correct temporal coverage',
     xpath: "/doc/field[@name='temporal_coverages'][1]",
     expected_text: ''
    },
    {
      title: 'should grab the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: '1096'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal'][1]",
      expected_text: '00.010101 30.000101'
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
      expected_text: 'Between 1 and 170 degrees of latitude change | Regional'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end
  puts "\n\n==============\n"
end
