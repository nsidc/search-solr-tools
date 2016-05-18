require 'spec_helper'

describe SearchSolrTools::Translators::GtnpJsonToSolr do
  header_entry = { 'title' => 'A title', 'abstract' => 'A summary' }
  valid_boreholes = {
    'name' => 'Keller 4. King George Island',
    'link' => 'http://gtnpdatabase.org/boreholes/view/646',
    'coordinates' => {
      'projection' => 'EPSG:4326',
      'latitude' => -62.075753,
      'longitude' => -58.403733
    },
    'citation' => {
      'contacts' => [
        {
          'givenName'  => 'Fred',
          'familyName' => 'Ethel'
        },
        {
          'givenName'  => 'Nikolay',
          'familyName' => 'Shiklomanov'
        }
      ]
    }
  }

  valid_activelayers = {
    'name' => 'Happy Valley 1km',
    'link' => 'http://gtnpdatabase.org/activelayers/view/1',
    'geo' => {
      'coordinates' => {
        'projection' => 'EPSG:4326',
        'latitude' => 69.100007,
        'longitude' => -148.498186
      }
    },
    'citation' => {
      'contacts' => []
    }
  }

  before :each do
    @translator = described_class.new
  end

  it 'successfully translates people names' do
    expect(@translator.parse_people(valid_boreholes)).to eql ['Fred Ethel', 'Nikolay Shiklomanov']
  end

  it 'successfully translates latitude/longitude coordinates into spatial coverage' do
    result = @translator.translate_geometry(valid_boreholes['coordinates'])
    expect(result[:spatial_display]).to eq ['-62.075753 -58.403733 -62.075753 -58.403733']
    expect(result[:spatial_index]).to eq ['-58.403733 -62.075753']
    expect(result[:spatial_area]).to eq 0.0
    expect(result[:spatial_scope_facet]).to eq ['Less than 1 degree of latitude change | Local']
  end

  it 'successfully translates a GTN-P active layers feed record' do
    result = @translator.translate(valid_activelayers, header_entry)
    title_id = "#{header_entry['title']} - #{valid_activelayers['name']}"
    expect(result['title']).to eql title_id
    expect(result['authoritative_id']).to eql title_id
    expect(result['data_centers']).to eql 'Global Terrestrial Network for Permafrost'
    expect(result['facet_data_center']).to eql 'Global Terrestrial Network for Permafrost | GTN-P'
    expect(result['summary']).to eql 'A summary'
    expect(result['dataset_url']).to eql 'http://gtnpdatabase.org/activelayers/view/1'
    expect(result['source']).to eql 'ADE'
    expect(result['facet_spatial_scope']).to eql ['Less than 1 degree of latitude change | Local']
    expect(result['spatial_coverages']).to eql ['69.100007 -148.498186 69.100007 -148.498186']
    expect(result['spatial_area']).to be 0.0
    expect(result['spatial']).to eql ['-148.498186 69.100007']
    expect(result['temporal_coverages']).to eql 'Not specified'
    expect(result['facet_temporal_duration']).to eql 'Not specified'
    expect(result['authors']).to eql []
  end

  it 'successfully translates a GTN-P borehole feed record' do
    result = @translator.translate(valid_boreholes, header_entry)
    title_id = "#{header_entry['title']} - #{valid_boreholes['name']}"
    expect(result['title']).to eql title_id
    expect(result['authoritative_id']).to eql title_id
    expect(result['data_centers']).to eql 'Global Terrestrial Network for Permafrost'
    expect(result['facet_data_center']).to eql 'Global Terrestrial Network for Permafrost | GTN-P'
    expect(result['summary']).to eql 'A summary'
    expect(result['dataset_url']).to eql 'http://gtnpdatabase.org/boreholes/view/646'
    expect(result['source']).to eql 'ADE'
    expect(result['facet_spatial_scope']).to eql ['Less than 1 degree of latitude change | Local']
    expect(result['spatial_coverages']).to eql ['-62.075753 -58.403733 -62.075753 -58.403733']
    expect(result['spatial_area']).to be 0.0
    expect(result['spatial']).to eql ['-58.403733 -62.075753']
    expect(result['temporal_coverages']).to eql 'Not specified'
    expect(result['facet_temporal_duration']).to eql 'Not specified'
    expect(result['authors']).to eql ['Fred Ethel', 'Nikolay Shiklomanov']
  end
end
