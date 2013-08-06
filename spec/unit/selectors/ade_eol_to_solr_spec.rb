require 'iso_to_solr'

describe 'EOL ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/unit/fixtures/eol_iso.xml')
  iso_to_solr = IsoToSolr.new(:eol)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'Low Rate Navigation, State Parameter, and Microphysics Flight-Level Data [NCAR/EOL]'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'This data set includes airborne measurements obtained from the NCAR Research Aviation Facility (RAF) ' +
      'Electra aircraft (Tail Number: N308D) during the BOReal Ecosystem Atmosphere Study (BOREAS). ' +
      'This dataset contains low rate navigation, state parameter, and microphysics flight-level data in NetCDF format.'
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'UCAR/NCAR - Earth Observing Laboratory / Computing, Data, and Software Facility'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://data.eol.ucar.edu/codiac/dss/id=234.001'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2011-05-19T09:49:14Z'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages']",
      expected_text: '1994-05-25T15:54:12Z,1994-09-16T22:35:43Z'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '19.940525 19.940916'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end

end
