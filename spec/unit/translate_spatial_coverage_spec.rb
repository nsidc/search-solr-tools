require 'selectors/helpers/translate_spatial_coverage'

describe TranslateSpatialCoverage do

  it 'translates GeoJSON polygon to spatial display str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 90.0], [180.0, 90.0], [180.0, 30.98], [-180.0, 30.98], [-180.0, 90.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -39.23], [180.0, -39.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -39.23]]])]
    spatial_display_strs = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_display_str(spatial_coverages_json)
    spatial_display_strs.length.should eql 2
    spatial_display_strs[0].should eql '30.98 -180.0 90.0 180.0'
    spatial_display_strs[1].should eql '-90.0 -180.0 -39.23 180.0'
  end

  it 'translates GeoJSON point to spatial display str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    spatial_display_strs = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_display_str(spatial_coverages_json)
    spatial_display_strs.length.should eql 1
    spatial_display_strs[0].should eql '-85.0 166.0 -85.0 166.0'
  end

  it 'translates GeoJSON polygon to spatial index str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 90.0], [180.0, 90.0], [180.0, 30.98], [-180.0, 30.98], [-180.0, 90.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -39.23], [180.0, -39.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -39.23]]])]
    spatial_index_strs = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_index_str(spatial_coverages_json)
    spatial_index_strs.length.should eql 2
    spatial_index_strs[0].should eql '-180.0 30.98 180.0 90.0'
    spatial_index_strs[1].should eql '-180.0 -90.0 180.0 -39.23'
  end

  it 'translates GeoJSON point to spatial index str' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    spatial_display_strs = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_index_str(spatial_coverages_json)
    spatial_display_strs.length.should eql 1
    spatial_display_strs[0].should eql '166.0 -85.0'
  end

  it 'translates GeoJSON geometries to single maximum spatial area value' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 90.0], [180.0, 90.0], [180.0, 32.98], [-180.0, 32.98], [-180.0, 90.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]]),
                              RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    area = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_area(spatial_coverages_json)
    area.round(2).should eql 58.77
  end

  it 'translates GeoJSON geometries with global value to single global facet value' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 86.0], [180.0, 86.0], [180.0, -86.0], [-180.0, -86.0], [-180.0, 86.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]]),
                              RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    global_facet = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_global_facet(spatial_coverages_json)
    global_facet.should eql 'Show Global Only'
  end

  it 'translates GeoJSON geometries with no global values to single non-global facet value' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]]),
                              RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    global_facet = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_global_facet(spatial_coverages_json)
    global_facet.should be_nil
  end

  it 'translates GeoJSON without geometries to single no spatial facet value' do
    spatial_coverages_json = []
    global_facet = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_global_facet(spatial_coverages_json)
    global_facet.should be_nil
  end

  it 'translates GeoJSON with multiple geometries to multiple scope values' do
    spatial_coverages_json = [RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, 86.0], [180.0, 86.0], [180.0, -86.0], [-180.0, -86.0], [-180.0, 86.0]]]),
                              RGeo::GeoJSON.decode('type' => 'Polygon', 'coordinates' => [[[-180.0, -31.23], [180.0, -31.23], [180.0, -90.0], [-180.0, -90.0], [-180.0, -31.23]]]),
                              RGeo::GeoJSON.decode('type' => 'Point', 'coordinates' => [166.0, -85.0])]
    scope_facet = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_scope_facet(spatial_coverages_json)
    scope_facet.length.should eql 3
    scope_facet.should include 'Coverage from over 85 degrees North to -85 degrees South | Global'
    scope_facet.should include 'Less than 1 degree of latitude change | Local'
    scope_facet.should include 'Between 1 and 170 degrees of latitude change | Regional'
  end

  it 'translates GeoJSON with without geometries to nil values' do
    spatial_coverages_json = []
    scope_facet = TranslateSpatialCoverage.translate_spatial_coverage_geom_to_spatial_scope_facet(spatial_coverages_json)
    scope_facet.length.should eql 0
  end
end
