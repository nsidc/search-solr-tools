require 'ade_iso_to_solr'

describe 'CISL ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/fixtures/cisl_iso.xml')
  iso_to_solr = ADEIsoToSolr.new(:cisl)
  solr_doc = iso_to_solr.translate fixture

  it 'should grab the correct title' do
    solr_doc.xpath("/doc/field[@name='title']").text.should be ==
    'Carbon Isotopic Values of Alkanes Extracted from Paleosols'
  end

  it 'should grab the correct summary' do
    solr_doc.xpath("/doc/field[@name='summary']").text.should be ==
    "\nDataset consists of compound specific carbon isotopic values of alkanes\nextracted from paleosols." +
    " Values represent the mean of duplicate\nmeasurements.\n"
  end

  it 'should grab the correct data center' do
    solr_doc.xpath("/doc/field[@name='data_centers']").text.should be ==
    'Advanced Cooperative Arctic Data and Information Service'
  end

  it 'should grab the correct get data link' do
    solr_doc.xpath("/doc/field[@name='dataset_url']").text.should be ==
    'http://www.aoncadis.org/dataset/id/005f3222-7548-11e2-851e-00c0f03d5b7c.html'
  end

  it 'should grab the correct updated date' do
    solr_doc.xpath("/doc/field[@name='last_revision_date']").text.should be ==
    '2013-02-13T00:00:00Z'
  end

  it 'should grab the correct source' do
    solr_doc.xpath("/doc/field[@name='source']").text.should be ==
    'ADE'
  end

end
