require 'iso_to_solr'

describe 'NODC ISO with Bad Spatial Bounds to Solr converter' do

  puts "\n\n-----------\n"
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/nodc_iso_bad_spatial.xml')
  iso_to_solr = IsoToSolr.new(:nodc)
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
      expected_text: 'Oceanographic profile Temperature and Salinity measurements collected during the Arctic Buoy Program using drifting buoy in the Arctic from 1985-1994 (NODC Accession 0001497)'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: ''
    },
    {
      title: 'should grab the correct data_centers',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'NOAA National Oceanographic Data Center'
    },
    {
      title: 'should include the correct authors',
      xpath: "/doc/field[@name='authors']",
      expected_text: ''
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords']",
      expected_text: ''
    },
    {
      # TODO: add a dummy sensor to the fixture [MB 2013-12-27]
      title: 'should grab the correct first sensor',
      xpath: "/doc/field[@name='sensors']",
      expected_text: ''
    },
    {
      title: 'should grab the correct dataset_url link',
      xpath: "/doc/field[@name='dataset_url']",
      # NOTE: I'm grabbing the FTP link explicitly.  NODC has really good data
      # access links with other representations available.
      expected_text: ''
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2013-06-03T00:00:00Z'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages']",
      expected_text: '60 90'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: '60 90'
    },
    {
     title: 'should grab the correct temporal coverage',
     xpath: "/doc/field[@name='temporal_coverages']",
     expected_text: '1985-04-13,1994-11-23'
    },
    {
      title: 'should grab the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: '3512'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '19.850413 19.941123'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end
  puts "\n\n==============\n"
end
