require 'spec_helper'

describe SearchSolrTools::Helpers::UsgsFormat do
  describe 'converting date strings to Hash date ranges' do
    it 'converts YYYY-MM-DD to a date range with that date as the start and end date' do
      expect(described_class.single_date_to_range('2004-04-07')).to eql(start: '2004-04-07', end: '2004-04-07')
    end

    it 'converts YYYY to a date range from Jan 1 to Dec 31 of that year' do
      expect(described_class.year_to_range('2003')).to eql(start: '2003-01-01', end: '2003-12-31')
    end
  end

  describe 'converting "Time Period" ISO elements to date ranges' do
    fixture = Nokogiri.XML File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'usgs_iso.xml'))

    selector = SearchSolrTools::Helpers::SELECTORS[:usgs][:temporal][:xpaths].first
    namespaces = SearchSolrTools::Helpers::IsoNamespaces.namespaces(fixture)

    it 'converts a single date to a date range with that date as the start and end date' do
      single_date_node = fixture.xpath(selector, namespaces)[0]
      expect(described_class.date_range(single_date_node)).to eql(start: '2004-04-07', end: '2004-04-07')
    end

    it 'converts a year to a date range from Jan 1 to Dec 31 of that year' do
      year_node = fixture.xpath(selector, namespaces)[1]
      expect(described_class.date_range(year_node)).to eql(start: '2003-01-01', end: '2003-12-31')
    end
  end
end
