require 'nokogiri'
require File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'selectors', 'helpers', 'usgs_format')
require File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'selectors', 'helpers', 'iso_namespaces')
require File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'selectors', 'helpers', 'selectors')

describe 'converting date strings to Hash date ranges' do
  it 'converts YYYY-MM-DD to a date range with that date as the start and end date' do
    UsgsFormat.single_date_to_range('2004-04-07').should eql(start: '2004-04-07', end: '2004-04-07')
  end

  it 'converts YYYY to a date range from Jan 1 to Dec 31 of that year' do
    UsgsFormat.year_to_range('2003').should eql(start: '2003-01-01', end: '2003-12-31')
  end
end

describe 'converting "Time Period" ISO elements to date ranges' do
  fixture = Nokogiri.XML File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'usgs_iso.xml'))

  selector = SELECTORS[:usgs][:temporal][:xpaths].first
  namespaces = IsoNamespaces.namespaces(fixture)

  it 'converts a single date to a date range with that date as the start and end date' do
    single_date_node = fixture.xpath(selector, namespaces)[0]
    UsgsFormat.date_range(single_date_node).should eql(start: '2004-04-07', end: '2004-04-07')
  end

  it 'converts a year to a date range from Jan 1 to Dec 31 of that year' do
    year_node = fixture.xpath(selector, namespaces)[1]
    UsgsFormat.date_range(year_node).should eql(start: '2003-01-01', end: '2003-12-31')
  end
end
