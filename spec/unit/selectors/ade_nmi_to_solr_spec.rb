require 'iso_to_solr'

describe 'NMI ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/fixtures/nmi_iso.xml')
  iso_to_solr = IsoToSolr.new(:nmi)
  solr_doc = iso_to_solr.translate fixture

  it 'should grab the correct title' do
    solr_doc.xpath("/doc/field[@name='title']").text.should be ==
    'ECMWF deterministic model forecast'
  end

  it 'should grab the correct summary' do
    solr_doc.xpath("/doc/field[@name='summary']").text.should be ==
    "\nProducts from the ECMWF Atmospheric Deterministic medium-range weather forecasts up to ten\ndays. " +
    "Check out http://www.ecmwf.int/ for details. The model output has been subsetted, reprojected\nand " +
    "reformatted using FIMEX (http://wiki.met.no/fimex/). \n"
  end

  it 'should grab the correct data center' do
    solr_doc.xpath("/doc/field[@name='data_centers']").text.should be == 'Norwegian Meteorological Institute'
  end

  it 'should grab the correct get data link' do
    solr_doc.xpath("/doc/field[@name='dataset_url']").text.should be ==
    'http://thredds.met.no/thredds/catalog/data/met.no/ecmwf/'
  end

  it 'should grab the correct updated date' do
    solr_doc.xpath("/doc/field[@name='last_revision_date']").text.should be ==
    '2009-11-11T00:00:00Z'
  end

  it 'should grab the correct source' do
    solr_doc.xpath("/doc/field[@name='source']").text.should be ==
    'ADE'
  end

end
