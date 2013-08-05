require 'iso_to_solr'

describe 'NSIDC ISO to SOLR converter' do
  fixture = Nokogiri.XML File.open('spec/fixtures/nsidc_iso.xml')
  iso_to_solr = IsoToSolr.new(:nsidc)
  solr_doc = iso_to_solr.translate fixture

  it 'should include the correct authoritative id' do
    solr_doc.at_xpath("/doc/field[@name='authoritative_id']").text.should eql 'NSIDC-0001'
  end

  it 'should include the correct version id' do
    solr_doc.at_xpath("/doc/field[@name='dataset_version']").text.should eql '4'
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

  it 'should include the correct keywords' do
    solr_doc.xpath("/doc/field[@name='keywords']").first.text.strip.should eql 'Theme'
  end

  it 'should include the correct parameters' do
    params = solr_doc.xpath("/doc/field[@name='parameters']")
    params.length.should eql 2
    params.last.text.strip.should eql 'SubDiscipline'
  end

  it 'should include the correct full string parameters' do
    solr_doc.xpath("/doc/field[@name='full_parameters']").first.text.strip.should eql 'Discipline > SubDiscipline'
  end

  it 'should include the correct platforms' do
    solr_doc.xpath("/doc/field[@name='platforms']").first.text.strip.should eql 'DMSP 5D-3/F17 > Defense Meteorological Satellite Program-F17'
  end

  it 'should include the correct instruments' do
    solr_doc.xpath("/doc/field[@name='sensors']").first.text.strip.should eql 'SSMIS > Special Sensor Microwave Imager/Sounder'
  end

  it 'should include brokered as true' do
    solr_doc.xpath("/doc/field[@name='brokered']").first.text.strip.should eql 'true'
  end

  it 'should include the correct published date' do
    solr_doc.xpath("/doc/field[@name='published_date']").first.text.strip.should eql '2004-05-10T00:00:00Z'
  end

  it 'should include the correct spatial coverages' do
    solr_doc.xpath("/doc/field[@name='spatial_coverages']").first.text.strip.should eql '-180,30.98,180,90'
    solr_doc.xpath("/doc/field[@name='spatial_coverages']").last.text.strip.should eql '-180,-90,180,-39.23'
  end

  it 'should include the correct spatial values' do
    solr_doc.xpath("/doc/field[@name='spatial']").first.text.strip.should eql '-180 30.98 180 90'
    solr_doc.xpath("/doc/field[@name='spatial']").last.text.strip.should eql '-180 -90 180 -39.23'
  end

  it 'should include the correct temporal coverages' do
    solr_doc.xpath("/doc/field[@name='temporal_coverages']").first.text.strip.should eql '1978-10-01,2011-12-31'
  end

  it 'should include the correct temporal values' do
    solr_doc.xpath("/doc/field[@name='temporal']")[0].text.should eql '19.781001 20.111231'
    solr_doc.xpath("/doc/field[@name='temporal']")[1].text.should eql '0 20.111231'
    solr_doc.xpath("/doc/field[@name='temporal']")[2].text.should eql '19.781001 30.000101'
  end

  it 'should include the correct data access urls' do
    solr_doc.xpath("/doc/field[@name='data_access_urls']").first.text.strip.should eql 'ftp://sidads.colorado.edu/pub/DATASETS/fgdc/ggd221_soiltemp_antarctica/'
  end

  it 'should include the correct distribution formats' do
    solr_doc.xpath("/doc/field[@name='distribution_formats']").first.text.strip.should eql 'ASCII Text'
  end

  it 'should include the correct popularity' do
    solr_doc.xpath("/doc/field[@name='popularity']").first.text.strip.should eql '10'
  end

  it 'should inlcude the correct sources' do
    solr_doc.xpath("/doc/field[@name='source']").first.text.strip.should eql 'NSIDC'
    solr_doc.xpath("/doc/field[@name='source']").last.text.strip.should eql 'ADE'
  end
end