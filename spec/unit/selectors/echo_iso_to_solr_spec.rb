require 'iso_to_solr'

describe 'ECHO ISO to Solr converter' do

  puts "\n\n-----------\n"
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/echo_iso.xml')
  iso_to_solr = IsoToSolr.new(:echo)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
   {
      title: 'should grab the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: 'gov.nasa.echo:15 Minute Stream Flow Data: USGS (FIFE)'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'doi:10.3334/ORNLDAAC/1 > 15 Minute Stream Flow Data: USGS (FIFE)'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'ABSTRACT: USGS 15 minute stream flow data for Kings Creek on the Konza Prairie'
    },
    {
      title: 'should grab the correct data_centers',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'NASA Earth Observing System (EOS) Clearing House (ECHO)'
    },
    {
      title: 'should include the correct authors',
      xpath: "/doc/field[@name='authors']",
      expected_text: ''
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords']",
      expected_text: 'EARTH SCIENCE>HYDROSPHERE>SURFACE WATER>DISCHARGE/FLOW>NONE>NONE>NONEEARTH SCIENCE>HYDROSPHERE>SURFACE WATER>STAGE HEIGHT>NONE>NONE>NONEORNL_DAACFIFE > FIFEESIP > Earth Science Information Partners ProgramEOSDIS > Earth Observing System Data Information SystemSURFACE WATER WEIR > SURFACE WATER WEIRSTILLING WELL > STILLING WELL'
    },
   {
      title: 'should grab the correct dataset_url link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://daac.ornl.gov/FIFE/guides/15_min_strm_flow.html'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2008-12-02T00:00:00Z'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages']",
      expected_text: '39.1 -96.6 39.1 -96.6'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: '-96.6 39.1 -96.6 39.1'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area']",
      expected_text: '0.0'
    },
    {
     title: 'should grab the correct temporal coverage',
     xpath: "/doc/field[@name='temporal_coverages']",
     expected_text: '1984-12-25T00:00:00Z,1988-03-04T00:00:00Z'
    },
    {
      title: 'should grab the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: '1166'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '19.841225 19.880304'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct spatial facet',
      xpath: "/doc/field[@name='facet_spatial_coverage']",
      expected_text: 'Non Global'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end
  puts "\n\n==============\n"
end
