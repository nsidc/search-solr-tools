require 'spec_helper'
require 'search_solr_tools/helpers/translate_temporal_coverage'

describe SearchSolrTools::Helpers::TranslateTemporalCoverage do
  it 'generates temporal values from JSON' do
    temporal_coverages_json = [{ 'start' => '1986-12-14T00:00:00-07:00', 'end' => '1992-11-13T00:00:00-07:00' },
                               { 'start' => '', 'end' => '1992-01-18T00:00:00-07:00' },
                               { 'start' => '', 'end' => '' },
                               { 'start' => '1986-12-01T00:00:00-04:00', 'end' => '1986-12-02T00:00:00-04:00' }]
    temporal_values = described_class.translate_coverages(temporal_coverages_json)
    expect(temporal_values['temporal_coverages'][0]).to eql('1986-12-14,1992-11-13')
    expect(temporal_values['temporal_duration']).to eql 2162
    expect(temporal_values['temporal'][0]).to eql '19.861214 19.921113'
    expect(temporal_values['facet_temporal_duration']).to eql ['1+ years', '5+ years']
  end

  it 'generates temporal value defaults when there are none present' do
    temporal_values = described_class.translate_coverages([])
    expect(temporal_values['temporal_coverages']).to eql []
    expect(temporal_values['temporal_duration']).to eql nil
    expect(temporal_values['temporal']).to eql []
    expect(temporal_values['facet_temporal_duration']).to eql SearchSolrTools::Helpers::SolrFormat::NOT_SPECIFIED
  end

  it 'generates a temporal duration value based on the longest single temporal coverage' do
    temporal_coverages_json = [{ 'start' => '1956-01-01T00:00:00-07:00', 'end' => '1964-01-01T00:00:00-07:00' },
                               { 'start' => '1994-01-01T00:00:00-07:00', 'end' => '1996-01-01T00:00:00-07:00' }]
    temporal_values = described_class.translate_coverages(temporal_coverages_json)
    expect(temporal_values['temporal_duration']).to eql 2923
    expect(temporal_values['facet_temporal_duration']).to eql ['1+ years', '5+ years']
  end

  it 'generates correct start values when no start date is specified' do
    temporal_coverages_json = [{ 'start' => '', 'end' => '1992-01-01T00:00:00-07:00' }]
    temporal_values = described_class.translate_coverages(temporal_coverages_json)
    expect(temporal_values['temporal_coverages']).to eql [',1992-01-01']
    expect(temporal_values['temporal_duration']).to eql nil
    expect(temporal_values['temporal']).to eql ['00.010101 19.920101']
    expect(temporal_values['facet_temporal_duration']).to eql SearchSolrTools::Helpers::SolrFormat::NOT_SPECIFIED
  end
end
