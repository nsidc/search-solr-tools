require 'iso_to_solr'

describe 'NSIDC ISO to SOLR converter' do
  fixture = Nokogiri.XML File.open('spec/fixtures/nsidc_iso.xml')
  iso_to_solr = IsoToSolr.new(:nsidc)
  solr_doc = iso_to_solr.translate fixture

  it 'should include the correct authoritative id' do
    solr_doc.at_xpath("/doc/field[@name='authoritative_id']").text.should eql 'NSIDC-0001'
  end

  it 'should include the correct title' do
    solr_doc.at_xpath("/doc/field[@name='title']").text.strip.should eql 'Test Title'
  end

  it 'should include the correct summary' do
    solr_doc.at_xpath("/doc/field[@name='summary']").text.strip.should eql 'Test Abstract'
  end

  it 'should include the correct authors' do
    solr_doc.xpath("/doc/field[@name='authors']").first.text.strip.should eql 'Jane Doe'
  end

  it 'should include the correct topics' do
    solr_doc.xpath("/doc/field[@name='topics']").first.text.strip.should eql 'climatology'
  end
end