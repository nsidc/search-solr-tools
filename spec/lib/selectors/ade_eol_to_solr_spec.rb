require 'iso_to_solr'

describe 'EOL ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/fixtures/eol_iso.xml')
  iso_to_solr = IsoToSolr.new(:eol)
  solr_doc = iso_to_solr.translate fixture

  it 'should grab the correct title' do
    solr_doc.xpath("/doc/field[@name='title']").text.should be ==
    'Low Rate Navigation, State Parameter, and Microphysics Flight-Level Data [NCAR/EOL]'
  end

  it 'should grab the correct summary' do
    solr_doc.xpath("/doc/field[@name='summary']").text.should be ==
    'This data set includes airborne measurements obtained from the NCAR Research Aviation Facility (RAF) ' +
    'Electra aircraft (Tail Number: N308D) during the BOReal Ecosystem Atmosphere Study (BOREAS). ' +
    'This dataset contains low rate navigation, state parameter, and microphysics flight-level data in NetCDF format.'
  end

  it 'should grab the correct data center' do
    solr_doc.xpath("/doc/field[@name='data_centers']").text.should be ==
    'UCAR/NCAR - Earth Observing Laboratory / Computing, Data, and Software Facility'
  end

  it 'should grab the correct get data link' do
    solr_doc.xpath("/doc/field[@name='dataset_url']").text.should be ==
    'http://data.eol.ucar.edu/codiac/dss/id=234.001'
  end

  it 'should grab the correct updated date' do
    solr_doc.xpath("/doc/field[@name='last_revision_date']").text.should be ==
    '2011-05-19T09:49:14Z'
  end

  it 'should grab the correct source' do
    solr_doc.xpath("/doc/field[@name='source']").text.should be ==
    'ADE'
  end

end
