require 'iso_to_solr'

describe 'NMI ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/unit/fixtures/nmi_iso.xml')
  iso_to_solr = IsoToSolr.new(:nmi)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'ECMWF deterministic model forecast'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='summary']",
      expected_text: "Products from the ECMWF Atmospheric Deterministic medium-range weather forecasts up to ten\ndays. " +
      "Check out http://www.ecmwf.int/ for details. The model output has been subsetted, reprojected\nand " +
      'reformatted using FIMEX (http://wiki.met.no/fimex/).'
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'Norwegian Meteorological Institute'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://thredds.met.no/thredds/catalog/data/met.no/ecmwf/'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2009-11-11T00:00:00Z'
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

end
