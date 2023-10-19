# frozen_string_literal: true

require 'spec_helper'

describe 'SOLR format methods' do
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/nsidc_iso.xml')
  json_fixture = JSON.parse(File.read('spec/unit/fixtures/nsidc_G02199.json'))
  bin_configuration = File.read('spec/unit/fixtures/bin_configuration.json')

  describe 'date' do
    it 'generates a SOLR readable ISO 8601 string using the DATE helper' do
      expect(SearchSolrTools::Helpers::SolrFormat::DATE.call(fixture.xpath('.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date'))).to eql '2004-05-10T00:00:00Z'
    end

    it 'generates a SOLR readable ISO 8601 string from a date obect' do
      expect(SearchSolrTools::Helpers::SolrFormat.date_str(DateTime.new(2013, 1, 1))).to eql '2013-01-01T00:00:00Z'
    end

    it 'generates a SOLR readable ISO 8601 string from a string' do
      expect(SearchSolrTools::Helpers::SolrFormat.date_str('2013-01-01')).to eql '2013-01-01T00:00:00Z'
    end

    it 'generates a SOLR readable ISO 8601 string string with extra spaces' do
      expect(SearchSolrTools::Helpers::SolrFormat.date_str('    2013-01-01 ')).to eql '2013-01-01T00:00:00Z'
    end
  end

  describe 'temporal' do
    it 'uses only the maximum duration when a dataset has multiple temporal ranges' do
      durations = [27, 123, 325, 234, 19_032, 3]
      expect(SearchSolrTools::Helpers::SolrFormat.reduce_temporal_duration(durations)).to be 19_032
    end
  end

  describe 'facets' do
    before do
      stub_request(:get, 'http://integration.nsidc.org/api/dataset/metadata/binConfiguration').with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => GZIP_DEFLATE_IDENTITY, 'User-Agent' => 'Ruby' }).to_return(status: 200, body: bin_configuration, headers: {})
    end

    it 'sets the parameter for a variable level_1' do
      node = fixture.xpath('.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="discipline"]//gmd:keyword/gco:CharacterString')[0].text
      expect(SearchSolrTools::Helpers::SolrFormat.parameter_binning(node)).to eql 'ICE EXTENT'
    end

    it 'bins the parameter' do
      node = fixture.xpath('.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="discipline"]//gmd:keyword/gco:CharacterString')[1].text
      expect(SearchSolrTools::Helpers::SolrFormat.parameter_binning(node)).to eql 'OCEAN PROPERTIES (OTHER)'
    end

    it 'does not set parameters that do not have variable level_1' do
      node = fixture.xpath('.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="discipline"]//gmd:keyword/gco:CharacterString')[2].text
      expect(SearchSolrTools::Helpers::SolrFormat.parameter_binning(node)).to be_nil
    end

    it 'sets the data format' do
      node = fixture.xpath('.//gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString')[0].text
      expect(SearchSolrTools::Helpers::SolrFormat.facet_binning('format', node)).to eql 'HTML'
    end

    it 'bins the data format' do
      node = fixture.xpath('.//gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString')[1].text
      expect(SearchSolrTools::Helpers::SolrFormat.facet_binning('format', node)).to eql 'ASCII TEXT'
    end

    it 'does not set excluded data formats' do
      node = fixture.xpath('.//gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString')[2].text
      expect(SearchSolrTools::Helpers::SolrFormat.facet_binning('format', node)).to be_nil
    end

    it 'sets the sensor' do
      expect(SearchSolrTools::Helpers::SolrFormat.facet_binning('sensor', json_fixture['instruments'][0]['shortName'])).to eql 'MODIS'
    end

    it 'bins the sensor' do
      expect(SearchSolrTools::Helpers::SolrFormat.facet_binning('sensor', json_fixture['instruments'][1]['shortName'])).to eql 'TESTBIN'
    end

    describe 'temporal resolution facet' do
      it 'bins second and 59 minute values as Subhourly' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'PT1S' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Subhourly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'PT59M59S' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Subhourly'
      end

      it 'bins 1 hour value as Hourly' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'PT60M' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Hourly'
      end

      it 'bins 1:00:01 and 23:59:59 values as Subdaily' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'PT1H0M1S' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Subdaily'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'PT23H59M59S' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Subdaily'
      end

      it 'bins 1 and 2 day as Daily' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P1D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Daily'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P2D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Daily'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P1DT12H' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Daily'
      end

      it 'bins 3 and 8 days as Weekly' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P3D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Weekly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P8D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Weekly'
      end

      it 'bins 9 and 20 days as Submonthly' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P9D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Submonthly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P20D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Submonthly'
      end

      it 'bins 1 month, 21 days and 31 days as Monthly' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P1M' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Monthly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P21D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Monthly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P31D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Monthly'
      end

      it 'bins values less then 1 year as Subyearly' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P364D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Subyearly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P11M' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Subyearly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P3M' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Subyearly'
      end

      it 'bins 1 year as Yearly' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P1Y' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Yearly'
      end

      it 'bins values greater then 1 year as Multiyearly' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P2Y' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Multiyearly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P30Y' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Multiyearly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P1Y1D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Multiyearly'
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => 'P13M' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql 'Multiyearly'
      end

      it 'bins range as range of facet values' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'range', 'min_resolution' => 'PT3H', 'max_resolution' => 'P10D' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql %w[Subdaily Daily Weekly Submonthly]
      end

      it 'bins varies as varies' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'varies' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql SearchSolrTools::Helpers::SolrFormat::NOT_SPECIFIED
      end

      it 'returns not specified if the value is blank' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => '' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql SearchSolrTools::Helpers::SolrFormat::NOT_SPECIFIED
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'range', 'min_resolution' => '', 'max_resolution' => '' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql SearchSolrTools::Helpers::SolrFormat::NOT_SPECIFIED
      end

      it 'returns not specified if the type is not single or range' do
        expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'not a real type', 'resolution' => 'PT23H59M59S' }, :find_index_for_single_temporal_resolution_value, SearchSolrTools::Helpers::SolrFormat::TEMPORAL_RESOLUTION_FACET_VALUES)).to eql SearchSolrTools::Helpers::SolrFormat::NOT_SPECIFIED
      end
    end

    describe 'spatial resolution facet' do
      value_bins = { '0 - 500 m'    => ['1 m', '500 m'],
                     '501 m - 1 km' => ['501 m', '1000 m'],
                     '2 - 5 km'     => ['1001 m', '5000 m', '0.01 deg', '0.05 deg'],
                     '6 - 15 km'    => ['5001 m', '15000 m'],
                     '16 - 30 km'   => ['15001 m', '30000 m', '0.06 deg', '0.25 deg', '0.49 deg'],
                     '>30 km'       => ['30001 m', '100000 m', '0.5 deg', '1 deg', '5 deg'] }
      value_bins.each do |bin, values|
        values.each do |val|
          it "bins #{val} as #{bin}" do
            expect(SearchSolrTools::Helpers::SolrFormat.resolution_value({ 'type' => 'single', 'resolution' => val }, :find_index_for_single_spatial_resolution_value, SearchSolrTools::Helpers::SolrFormat::SPATIAL_RESOLUTION_FACET_VALUES)).to eql bin
          end
        end
      end
    end

    describe '#spatial_resolution_index_degrees' do
      def described_method(degrees)
        SearchSolrTools::Helpers::SolrFormat.spatial_resolution_index_degrees(degrees)
      end

      it 'returns the 2-5 km index for 0 degrees' do
        expect(described_method(0)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_2_5_INDEX
      end

      it 'returns the 2-5 km index for 0.05 degrees' do
        expect(described_method(0.05)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_2_5_INDEX
      end

      it 'returns the 16-30 km index for 0.06 degrees' do
        expect(described_method(0.06)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_16_30_INDEX
      end

      it 'returns the 16-30 km index for 0.49 degrees' do
        expect(described_method(0.49)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_16_30_INDEX
      end

      it 'returns the >30 km index for 0.5 degrees' do
        expect(described_method(0.5)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_GREATER_30_INDEX
      end

      it 'returns the >30 km index for 180 degrees' do
        expect(described_method(180)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_GREATER_30_INDEX
      end
    end

    describe '#spatial_resolution_index_meters' do
      def described_method(meters)
        SearchSolrTools::Helpers::SolrFormat.spatial_resolution_index_meters(meters)
      end

      it 'returns the 0-500 m index for 0 meters' do
        expect(described_method(0)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_0_500_INDEX
      end

      it 'returns the 0-500 m index for 500 meters' do
        expect(described_method(500)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_0_500_INDEX
      end

      it 'returns the 501m - 1km index for 501 meters' do
        expect(described_method(501)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_501_1_INDEX
      end

      it 'returns the 501m - 1km index for 1_000 meters' do
        expect(described_method(1_000)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_501_1_INDEX
      end

      it 'returns the 2-5 km index for 1_001 meters' do
        expect(described_method(1_001)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_2_5_INDEX
      end

      it 'returns the 2-5 km index for 5_000 meters' do
        expect(described_method(5_000)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_2_5_INDEX
      end

      it 'returns the 6-15 km index for 5_001 meters' do
        expect(described_method(5_001)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_6_15_INDEX
      end

      it 'returns the 6-15 km index for 15_000 meters' do
        expect(described_method(15_000)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_6_15_INDEX
      end

      it 'returns the 16-30 km index for 15_001 meters' do
        expect(described_method(15_001)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_16_30_INDEX
      end

      it 'returns the 16-30 km index for 30_000 meters' do
        expect(described_method(30_000)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_16_30_INDEX
      end

      it 'returns the >30 km index for 30_001 meters' do
        expect(described_method(30_001)).to eql SearchSolrTools::Helpers::SolrFormat::SPATIAL_GREATER_30_INDEX
      end
    end
  end
end
