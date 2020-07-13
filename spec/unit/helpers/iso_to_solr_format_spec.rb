require 'spec_helper'
require 'search_solr_tools/helpers/iso_to_solr_format'

describe SearchSolrTools::Helpers::IsoToSolrFormat do
  describe '#get_temporal_duration' do
    let(:temporal_node) { double('temporal_node') }
    let(:date_range) { double('date_range') }

    def described_method(node)
      described_class.get_temporal_duration(node)
    end

    before(:each) do
      allow(described_class).to receive(:date_range).with(temporal_node).and_return(date_range)
    end

    describe 'with a start date' do
      before(:each) do
        allow(date_range).to receive(:[]).with(:start).and_return('2015-01-01')
      end

      describe 'with an end date' do
        before(:each) do
          allow(date_range).to receive(:[]).with(:end).and_return('2015-02-28')
        end

        it 'returns the result of calling SolrFormat.get_temporal_duration with the 2 dates in '\
           'Time objects' do
          expect(SearchSolrTools::Helpers::SolrFormat).to(
            receive(:get_temporal_duration).with(
              Time.parse(date_range[:start]),
              Time.parse(date_range[:end])
            ).and_return('something')
          )

          expect(described_method(temporal_node)).to eql('something')
        end
      end

      describe 'with no end date' do
        before(:each) do
          allow(date_range).to receive(:[]).with(:end).and_return(nil)
        end

        it 'returns the result of calling SolrFormat.get_temporal_duration with the given start '\
           'date and today' do
          now = Time.now
          allow(Time).to receive(:now).and_return(now)

          expect(SearchSolrTools::Helpers::SolrFormat).to(
            receive(:get_temporal_duration).with(
              Time.parse(date_range[:start]),
              now
            ).and_return('something')
          )

          expect(described_method(temporal_node)).to eql('something')
        end
      end
    end

    describe 'with no start date' do
      before(:each) do
        allow(date_range).to receive(:[]).with(:start).and_return(nil)
      end

      describe 'with an end date' do
        before(:each) do
          allow(date_range).to receive(:[]).with(:end).and_return('2015-02-28')
        end

        it 'returns nil' do
          expect(described_method(temporal_node)).to eql(nil)
        end
      end

      describe 'with no end date' do
        before(:each) do
          allow(date_range).to receive(:[]).with(:end).and_return(nil)
        end

        it 'returns nil' do
          expect(described_method(temporal_node)).to eql(nil)
        end
      end
    end
  end
end
