require 'iso_to_solr'

describe 'NODC ISO to Solr converter' do

  puts "\n\n-----------\n"
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/nodc_iso.xml')
  iso_to_solr = IsoToSolr.new(:nodc)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: 'AVHRR_Pathfinder-NODC-L3C-v5.2'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'AVHRR Pathfinder Version 5.2 Level 3 Collated (L3C) Global 4km Sea Surface Temperature for 1981-2011'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'The AVHRR Pathfinder Version 5.2 Sea Surface Temperature data set (PFV52) is a collection of global, [snip]'
    },
    {
      title: 'should grab the correct data_centers',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'DOC/NOAA/NODC > National Oceanographic Data Center, NOAA, U.S. Department of Commerce'
    },
    {
      title: 'should include the correct authors',
      xpath: "/doc/field[@name='authors'][1]",
      expected_text: 'Robert Evans'
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords'][1]",
      expected_text: 'Geographic Region > Global Ocean'
    },
    {
      title: 'should grab the correct first sensor',
      xpath: "/doc/field[@name='sensors'][1]",
      expected_text: 'Advanced Very High Resolution Radiometer - AVHRR'
    },
    {
      title: 'should grab the correct dataset_url link',
      xpath: "/doc/field[@name='dataset_url']",
      # NOTE: I'm grabbing the FTP link explicitly.  NODC has really good data
      # access links with other representations available.
      expected_text: 'ftp://ftp.nodc.noaa.gov/pub/data.nodc/pathfinder/Version5.2/'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2013-07-15'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages']",
      expected_text: '-90 -180 90 180'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: '-180 -90 180 90'
    },
    {
     title: 'should grab the correct temporal coverage',
     xpath: "/doc/field[@name='temporal_coverages']",
     expected_text: '1981-08-24T00:00:00Z,2011-12-31T00:00:00Z'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '19.810824 20.111231'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end
  puts "\n\n==============\n"
end
