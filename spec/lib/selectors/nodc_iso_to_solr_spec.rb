require 'iso_to_solr'

describe 'NODC ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/fixtures/nodc_iso.xml')
  iso_to_solr = IsoToSolr.new(:nodc)
  solr_doc = iso_to_solr.translate fixture

  it 'should grab the correct title' do
    solr_doc.xpath("/doc/field[@name='title']").text.should eql ''
  end

end
