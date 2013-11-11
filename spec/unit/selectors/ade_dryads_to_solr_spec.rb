require 'iso_to_solr'

describe 'Dryads ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/unit/fixtures/dryads_iso.xml')
  iso_to_solr = IsoToSolr.new(:dryads)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'Data from: Surprising complexity of the ancestral apoptosis network'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'Apoptosis, one of the main types of programmed cell death, is regulated and performed by a complex protein network. ' +
      'Studies in model organisms, mostly in the nematode C. elegans, identified a relatively simple apoptotic network consisting of only a few proteins. ' +
      'Similar results are beginning to surface for other regulatory networks, contradicting the intuitive notion that regulatory networks evolved in a linear way, from simple to complex.'
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'Dryad Digital Repository'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://datadryad.org/handle/10255/dryad.12'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2007-10-24T00:00:00Z'
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
