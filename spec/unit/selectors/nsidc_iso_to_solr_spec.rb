require 'iso_to_solr'
require 'date'

describe 'NSIDC ISO to SOLR converter' do
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/nsidc_iso.xml')
  iso_to_solr = IsoToSolr.new(:nsidc)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should include the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: 'NSIDC-0001'
    },
    {
      title: 'should include the correct version id',
      xpath: "/doc/field[@name='dataset_version']",
      expected_text: '4'
    },
    {
      title: 'should include the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'Test Title'
    },
    {
      title: 'should include the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: 'Test Abstract'
    },
    {
      title: 'should include the correct citation PI author',
      xpath: "/doc/field[@name='authors'][1]",
      expected_text: 'Jane Doe'
    },
    {
      title: 'should include the correct point of contact PI author',
      xpath: "/doc/field[@name='authors'][2]",
      expected_text: 'Frank J. Wentz'
    },
    {
      title: 'should include the correct point of contact data author',
      xpath: "/doc/field[@name='authors'][3]",
      expected_text: 'Marilyn Walker'
    },
    {
      title: 'should include the correct point of contact metadata author',
      xpath: "/doc/field[@name='authors'][4]",
      expected_text: 'Gene R. Major'
    },
    {
      title: 'should include the correct topics',
      xpath: "/doc/field[@name='topics'][1]",
      expected_text: 'climatology'
    },
    {
      title: 'should include the correct keywords',
      xpath: "/doc/field[@name='keywords'][1]",
      expected_text: 'Theme'
    },
    {
      title: 'should include the correct first parameter',
      xpath: "/doc/field[@name='parameters'][1]",
      expected_text: 'Discipline'
    },
    {
      title: 'should include the correct second parameter',
      xpath: "/doc/field[@name='parameters'][last()]",
      expected_text: 'SubDiscipline'
    },
    {
      title: 'should include the correct full string parameters',
      xpath: "/doc/field[@name='full_parameters'][1]",
      expected_text: 'Discipline > SubDiscipline'
    },
    {
      title: 'should include the correct platforms',
      xpath: "/doc/field[@name='platforms'][1]",
      expected_text: 'DMSP 5D-3/F17 > Defense Meteorological Satellite Program-F17'
    },
    {
      title: 'should include the correct instruments',
      xpath: "/doc/field[@name='sensors'][1]",
      expected_text: 'SSMIS > Special Sensor Microwave Imager/Sounder'
    },
    {
      title: 'should include brokered as true',
      xpath: "/doc/field[@name='brokered'][1]",
      expected_text: 'true'
    },
    {
      title: 'should include the correct published date',
      xpath: "/doc/field[@name='published_date'][1]",
      expected_text: '2004-05-10T00:00:00Z'
    },
    {
      title: 'should include the correct first spatial coverages',
      xpath: "/doc/field[@name='spatial_coverages'][1]",
      expected_text: '30.98 -180 90 180'
    },
    {
      title: 'should include the correct last spatial coverages',
      xpath: "/doc/field[@name='spatial_coverages'][last()]",
      expected_text: '-90 -180 -39.23 180'
    },
    {
      title: 'should include the first correct spatial values',
      xpath: "/doc/field[@name='spatial'][1]",
      expected_text: '-180 30.98 180 90'
    },
    {
      title: 'should include the last correct spatial values',
      xpath: "/doc/field[@name='spatial'][last()]",
      expected_text: '-180 -90 180 -39.23'
    },
    {
      title: 'should include the correct temporal coverages',
      xpath: "/doc/field[@name='temporal_coverages'][1]",
      expected_text: '1978-10-01,2011-12-31'
    },
    {
      title: 'should grab the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: "#{Integer(Time.now.to_date - Date.parse('1978-10-01')) + 1}"
    },
    {
      title: 'should include the first correct temporal values',
      xpath: "/doc/field[@name='temporal'][1]",
      expected_text: '19.781001 20.111231'
    },
    {
      title: 'should include the second correct temporal values',
      xpath: "/doc/field[@name='temporal'][2]",
      expected_text: '00.010101 20.111231'
    },
    {
      title: 'should include the third correct temporal values',
      xpath: "/doc/field[@name='temporal'][3]",
      expected_text: '19.781001 30.000101'
    },
    {
      title: 'should include the correct distribution formats',
      xpath: "/doc/field[@name='distribution_formats'][1]",
      expected_text: 'ASCII Text'
    },
    {
      title: 'should include the correct popularity',
      xpath: "/doc/field[@name='popularity'][1]",
      expected_text: '10'
    },
    {
      title: 'should include the correct first source',
      xpath: "/doc/field[@name='source'][1]",
      expected_text: 'NSIDC'
    },
    {
      title: 'should include the correct last source',
      xpath: "/doc/field[@name='source'][last()]",
      expected_text: 'ADE'
    },
    {
      title: 'should include the correct last revision date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2013-05-28T00:00:00Z'
    },
    {
      title: 'should include the sponsored program facet',
      xpath: "/doc/field[@name='facet_sponsored_program']",
      expected_text: 'MEaSUREs'
    }]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end

  it 'should exclude NSIDC User Services as an author' do
    solr_doc.xpath("/doc/field[@name='authors']").text.strip.should_not include('NSIDC User Services')
  end

  it 'should exclude duplicate authors' do
    solr_doc.xpath("/doc/field[@name='authors']").select { |a| a.text.strip.eql? 'Gene R. Major' }.length.should be 1
  end
end
