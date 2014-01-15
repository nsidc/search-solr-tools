require 'iso_to_solr'

describe 'RDA ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/unit/fixtures/rda_iso.xml')
  iso_to_solr = IsoToSolr.new(:rda)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'NCEP Version 2.0 OI Global SST and NCDC Version 3.0 Extended Reconstructed SST Analyses'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: "The NCEP OI is a weekly and monthly 1x1 global analysis dataset that is available for " +
      "November 1981 through a current date... Abbreviated for testing"
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'Data Support Section, Computational and Information Systems Laboratory, National Center for Atmospheric Research, University Corporation for Atmospheric Research'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: ''
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2014-01-01T00:00:00Z'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages']",
      expected_text: ''
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: ''
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages']",
      expected_text: '1854-01-01,2014-01-11'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '18.540101 20.140111'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end

end
