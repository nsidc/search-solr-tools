require 'spec_helper'
require 'date'

describe SearchSolrTools::Helpers::NcdcPaleoFormat do
  describe '#bounding_box' do
    it 'returns a bounding box' do
      node = Nokogiri::XML(File.open('spec/unit/fixtures/ncdc_paleo_bounding_box.xml')).at_xpath('//ows:WGS84BoundingBox')
      expect(described_class.bounding_box(node)).to match(north: '34', south: '28', east: '122', west: '116')
    end
  end

  describe '#date_range' do
    it "parses an 'cal yr BP date range'" do
      node = Nokogiri::XML("<dc:coverage xmlns:ds='test'>START YEAR: 11739 cal yr BP  * END YEAR: 11293 cal yr BP</dc:coverage>")
      expect(described_class.date_range(node)).to match(start: DateTime.strptime('-13689  ', '%Y'), end: DateTime.strptime('-13243', '%Y'))
    end

    it "parses an 'AD' date range" do
      node = Nokogiri::XML("<dc:coverage xmlns:ds='test'>START YEAR: 1856 AD  * END YEAR: 2013 AD</dc:coverage>")
      expect(described_class.date_range(node)).to match(start: DateTime.strptime('1856', '%Y'), end: DateTime.strptime('2013', '%Y'))
    end

    it "parses a '14C yr BP date range'" do
      node = Nokogiri::XML("<dc:coverage xmlns:ds='test'>START YEAR: 11739 14C yr BP  * END YEAR: 11293 14C yr BP</dc:coverage>")
      expect(described_class.date_range(node)).to match(start: DateTime.strptime('-13689  ', '%Y'), end: DateTime.strptime('-13243', '%Y'))
    end
  end

  describe '#get_tmeporal_duration' do
    it 'gets the temporal duration' do
      node = Nokogiri::XML("<dc:coverage xmlns:ds='test'>START YEAR: 1856 AD  * END YEAR: 2013 AD</dc:coverage>")
      expect(described_class.get_temporal_duration(node)).to eql 57_344
    end
  end
end
