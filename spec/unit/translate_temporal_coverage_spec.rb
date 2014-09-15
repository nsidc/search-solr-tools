require 'selectors/helpers/translate_temporal_coverage'

describe TranslateTemporalCoverage do
  it 'generates temporal values from JSON' do
    temporal_coverages_json = [{ 'start' => '1986-12-14T00:00:00-07:00', 'end' => '1992-11-13T00:00:00-07:00' },
                               { 'start' => '', 'end' => '1992-01-18T00:00:00-07:00' },
                               { 'start' => '', 'end' => '' },
                               { 'start' => '1986-12-01T00:00:00-04:00', 'end' => '1986-12-02T00:00:00-04:00' }]
    temporal_values = TranslateTemporalCoverage.translate_coverages(temporal_coverages_json)
    temporal_values['temporal_coverages'][0].should eql('1986-12-14,1992-11-13')
    temporal_values['temporal_duration'].should eql 2162
    temporal_values['temporal'][0].should eql '19.861214 19.921113'
    temporal_values['facet_temporal_duration'].should eql ['1+ years', '5+ years']
  end

  it 'generates temporal value defaults when there are none present in NSIDC JSON' do
    temporal_values = TranslateTemporalCoverage.translate_coverages([])
    temporal_values['temporal_coverages'].should eql []
    temporal_values['temporal_duration'].should eql nil
    temporal_values['temporal'].should eql []
    temporal_values['facet_temporal_duration'].should eql SolrFormat::NOT_SPECIFIED
  end

  it 'generates a temporal duration value based on the longest single temporal coverage' do
    temporal_coverages_json = [{ 'start' => '1956-01-01T00:00:00-07:00', 'end' => '1964-01-01T00:00:00-07:00' },
                               { 'start' => '1994-01-01T00:00:00-07:00', 'end' => '1996-01-01T00:00:00-07:00' }]
    temporal_values = TranslateTemporalCoverage.translate_coverages(temporal_coverages_json)
    temporal_values['temporal_duration'].should eql 2923
    temporal_values['facet_temporal_duration'].should eql ['1+ years', '5+ years']
  end

  it 'generates correct start values when no start date is specified' do
    temporal_coverages_json = [{ 'start' => '', 'end' => '1992-01-01T00:00:00-07:00' }]
    temporal_values = TranslateTemporalCoverage.translate_coverages(temporal_coverages_json)
    temporal_values['temporal_coverages'].should eql [',1992-01-01']
    temporal_values['temporal_duration'].should eql nil
    temporal_values['temporal'].should eql ['00.010101 19.920101']
    temporal_values['facet_temporal_duration'].should eql SolrFormat::NOT_SPECIFIED
  end
end
