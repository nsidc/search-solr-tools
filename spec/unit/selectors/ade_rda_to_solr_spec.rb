require 'selectors/helpers/iso_to_solr'

describe 'RDA ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/unit/fixtures/rda_oai.xml')
  iso_to_solr = IsoToSolr.new(:rda)
  solr_doc = iso_to_solr.translate(fixture)

  test_expectations = [
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'NCEP Version 2.0 OI Global SST and NCDC Version 4.0 Extended Reconstructed SST Analyses'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'The NCEP OI is a weekly and monthly 1 degree global analysis dataset that is available for November 1981 through a current date. The analyses are determined by blending marine surface observations (ICOADS and others) and satellite AVHRR data using an OI method. The NCDC ERSST Version 4 [http://www1.ncdc.noaa.gov/pub/data/cmb/ersst/v4/] is a monthly 2 degree global analysis for 1854 through a current date. EOF methods are used to create these grids using marine surface data (ICOADS). Various climate indexes (e.g. SOI) are available from the Climate Prediction Center [http://www.cpc.ncep.noaa.gov/data/indices/] Recent weekly OI SST plots and other products are available at NOAA OI SST Analysis page [http://www.emc.ncep.noaa.gov/research/cmb/sst_analysis/] Go to Merged Hadley - OI V2 SST and Sea Ice Concentration dataset [http://cdp.ucar.edu/MergedHadleyOI] for a new surface boundary dataset for uncoupled simulations with the Community Atmosphere Model (CAM).'
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'UCAR/NCAR Research Data Archive'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://rda.ucar.edu/datasets/ds277.3/'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages']",
      expected_text: '-90.0 -180.0 90.0 180.0'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: '-180.0 -90.0 180.0 90.0'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area']",
      expected_text: '180.0'
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages']",
      expected_text: '1854-01-15,2014-12-15'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '18.540115 20.141215'
    },
    {
      title: 'should calculate the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: '58774'
    },
    {
      title: 'should grab the correct spatial scope facet',
      xpath: "/doc/field[@name='facet_spatial_scope']",
      expected_text: 'Coverage from over 85 degrees North to -85 degrees South | Global'
    },
    {
      title: 'should grab the correct temporal duration facet',
      xpath: "/doc/field[@name='facet_temporal_duration']",
      expected_text: '1+ years5+ years10+ years'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end

  it 'should insert a default updated date' do
    date_str = solr_doc.xpath("/doc/field[@name='last_revision_date']").text
    expect { DateTime.parse(date_str) }.not_to raise_error
  end
end
