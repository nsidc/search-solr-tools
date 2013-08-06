require 'iso_to_solr'

describe 'CISL ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/unit/fixtures/cisl_iso.xml')
  iso_to_solr = IsoToSolr.new(:cisl)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'Carbon Isotopic Values of Alkanes Extracted from Paleosols'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: "Dataset consists of compound specific carbon isotopic values of alkanes\nextracted from paleosols." +
      " Values represent the mean of duplicate\nmeasurements."
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'Advanced Cooperative Arctic Data and Information Service'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://www.aoncadis.org/dataset/id/005f3222-7548-11e2-851e-00c0f03d5b7c.html'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2013-02-13T00:00:00Z'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages']",
      expected_text: '-180,-90,180,90'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: '-180 -90 180 90'
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages']",
      expected_text: '2012-06-09T06:00:00Z,2012-08-18T06:00:00Z'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '20.120609 20.120818'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end
end
