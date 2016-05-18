require 'spec_helper'

describe SearchSolrTools::Helpers::TranslateSpatialCoverage do
  it 'translates GeoJSON polygon to spatial display str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 90.0], [180.0, 90.0], [180.0, 30.98], [-180.0, 30.98], [-180.0, 90.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -39.23], [180.0, -39.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -39.23]]])]
    spatial_display_strs = described_class.geojson_to_spatial_display_str(spatial_coverages_json)
    expect(spatial_display_strs.length).to eql 2
    expect(spatial_display_strs[0]).to eql '30.98 -180.0 90.0 180.0'
    expect(spatial_display_strs[1]).to eql '-90.0 -180.0 -39.23 180.0'
  end

  it 'translates GeoJSON point to spatial display str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    spatial_display_strs = described_class.geojson_to_spatial_display_str(spatial_coverages_json)
    expect(spatial_display_strs.length).to eql 1
    expect(spatial_display_strs[0]).to eql '-85.0 166.0 -85.0 166.0'
  end

  it 'translates GGeoJSON multipoint to spatial display str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'MultiPoint', 'coordinates' => [[-117.8446, 33.6436], [-179.0000, -80], [-179.0000, 80], [179.0000, 80], [179.0000, -80], [0.0000, 0.0000], [0, 80], [-179.0000, 179.0000]])]
    translation = described_class.geojson_to_spatial_display_str(spatial_coverages_json)
    expect(translation).to eql ['33.6436 -117.8446 33.6436 -117.8446',
                                '-80.0 -179.0 -80.0 -179.0',
                                '80.0 -179.0 80.0 -179.0',
                                '80.0 179.0 80.0 179.0',
                                '-80.0 179.0 -80.0 179.0',
                                '0.0 0.0 0.0 0.0',
                                '80.0 0.0 80.0 0.0',
                                '179.0 -179.0 179.0 -179.0']
  end

  it 'translates GeoJSON polygon to spatial index str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 90.0], [180.0, 90.0], [180.0, 30.98], [-180.0, 30.98], [-180.0, 90.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -39.23], [180.0, -39.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -39.23]]])]
    spatial_index_strs = described_class.geojson_to_spatial_index_str(spatial_coverages_json)
    expect(spatial_index_strs.length).to eql 2
    expect(spatial_index_strs[0]).to eql '-180.0 30.98 180.0 90.0'
    expect(spatial_index_strs[1]).to eql '-180.0 -90.0 180.0 -39.23'
  end

  it 'translates GeoJSON point to spatial index str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    spatial_display_strs = described_class.geojson_to_spatial_index_str(spatial_coverages_json)
    expect(spatial_display_strs.length).to eql 1
    expect(spatial_display_strs[0]).to eql '166.0 -85.0'
  end

  it 'translates GeoJSON multipoint to spatial index str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'MultiPoint', 'coordinates' => [[-117.8446, 33.6436], [-179, -80], [50.22, 45.00], [0, 80], [-179.0000, 179.0000]])]
    spatial_display_strs = described_class.geojson_to_spatial_index_str(spatial_coverages_json)
    expect(spatial_display_strs).to eql ['-117.8446 33.6436',
                                         '-179.0 -80.0',
                                         '50.22 45.0',
                                         '0.0 80.0',
                                         '-179.0 179.0']
  end

  it 'translates GeoJSON geometries to single maximum spatial area value' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 90.0], [180.0, 90.0], [180.0, 32.98], [-180.0, 32.98], [-180.0, 90.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]]),
                              RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    area = described_class.geojson_to_spatial_area(spatial_coverages_json)
    expect(area.round(2)).to eql 58.77
  end

  it 'translates GeoJSON geometries with global value to single global facet value' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 86.0], [180.0, 86.0], [180.0, -86.0], [-180.0, -86.0], [-180.0, 86.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]]),
                              RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    global_facet = described_class.geojson_to_global_facet(spatial_coverages_json)
    expect(global_facet).to eql 'Show Global Only'
  end

  it 'translates GeoJSON geometries with no global values to single non-global facet value' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]]),
                              RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    global_facet = described_class.geojson_to_global_facet(spatial_coverages_json)
    expect(global_facet).to be_nil
  end

  it 'translates GeoJSON without geometries to single no spatial facet value' do
    spatial_coverages_json = []
    global_facet = described_class.geojson_to_global_facet(spatial_coverages_json)
    expect(global_facet).to be_nil
  end

  it 'translates GeoJSON with multiple geometries to multiple scope values' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 86.0], [180.0, 86.0], [180.0, -86.0], [-180.0, -86.0], [-180.0, 86.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]]),
                              RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    scope_facet = described_class.geojson_to_spatial_scope_facet(spatial_coverages_json)
    expect(scope_facet.length).to eql 3
    expect(scope_facet).to include 'Coverage from over 85 degrees North to -85 degrees South | Global'
    expect(scope_facet).to include 'Less than 1 degree of latitude change | Local'
    expect(scope_facet).to include 'Between 1 and 170 degrees of latitude change | Regional'
  end

  it 'translates GeoJSON with without geometries to nil values' do
    spatial_coverages_json = []
    scope_facet = described_class.geojson_to_spatial_scope_facet(spatial_coverages_json)
    expect(scope_facet.length).to eql 0
  end
end
