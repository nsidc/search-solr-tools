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
      expected_text: 'gov.noaa.nodc:9900244'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'DEPTH - OBSERVATION and Other Data from POLARSTERN and Other Platforms from 19240804 to 19991124 (NODC Accession 9900244)'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'Soil pore water collected from various drained thaw lake basins near Barrow, AK was analyzed for dissolved carbon dioxide and methane. Soil water samples (0-10 cm depth) were collected using Rhizon soil moisture samplers and dissolved gases were measured by GC analysis of the headspace.'
    },
    {
      title: 'should grab the correct data_centers',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'NOAA National Oceanographic Data Center'
    },
    {
      title: 'should include the correct authors',
      xpath: "/doc/field[@name='authors'][1]",
      expected_text: 'Robert Evans'
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords'][1]",
      expected_text: 'oceanography'
    },
    {
      # TODO: add a dummy sensor to the fixture [MB 2013-12-27]
      title: 'should grab the correct first sensor',
      xpath: "/doc/field[@name='sensors'][1]",
      expected_text: ''
    },
    {
      title: 'should grab the correct dataset_url link',
      xpath: "/doc/field[@name='dataset_url']",
      # NOTE: I'm grabbing the FTP link explicitly.  NODC has really good data
      # access links with other representations available.
      expected_text: 'ftp://ftp.nodc.noaa.gov/nodc/archive/arc0001/9900244/'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2013-07-15T00:00:00Z'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages']",
      expected_text: '0.3 -124.2 86.1 -144.2'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: '-124.2 0.3 -144.2 86.1'
    },
    {
     title: 'should grab the correct temporal coverage',
     xpath: "/doc/field[@name='temporal_coverages']",
     expected_text: '1924-08-04T00:00:00Z,1999-11-24T00:00:00Z'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '19.240804 19.991124'
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
