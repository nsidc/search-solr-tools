require 'iso_to_solr'

describe 'ECHO ECHO10 to Solr converter' do

  puts "\n\n-----------\n"
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/echo_echo10.xml')
  iso_to_solr = IsoToSolr.new(:echo)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
   {
      title: 'should grab the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: 'C179003030-ORNL_DAAC'
    },
   {
     title: 'should grab the correct title',
     xpath: "/doc/field[@name='title']",
     expected_text: '15 Minute Stream Flow Data: USGS (FIFE)'
   },
   {
     title: 'should grab the correct summary',
     xpath: "/doc/field[@name='summary']",
     expected_text: 'ABSTRACT: USGS 15 minute stream flow data for Kings Creek on the Konza Prairie'
   },
   {
     title: 'should grab the correct data_centers',
     xpath: "/doc/field[@name='data_centers']",
     expected_text: 'NASA Earth Observing System (EOS) Clearing House (ECHO)'
   },
   {
     title: 'should include the correct authors',
     xpath: "/doc/field[@name='authors']",
     expected_text: ''
   },
   {
     title: 'should include the correct keywords',
     xpath: "/doc/field[@name='keywords']",
     expected_text: 'EARTH SCIENCE > HYDROSPHERE > SURFACE WATEREARTH SCIENCE > HYDROSPHERE > SURFACE WATEREARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > BIOLOGICAL CLASSIFICATION > ANIMALS/VERTEBRATESEARTH SCIENCE > BIOLOGICAL CLASSIFICATION > ANIMALS/VERTEBRATESEARTH SCIENCE > BIOSPHERE > ECOLOGICAL DYNAMICSEARTH SCIENCE > BIOSPHERE > VEGETATIONEARTH SCIENCE > HUMAN DIMENSIONS > HABITAT CONVERSION/FRAGMENTATIONEARTH SCIENCE > HUMAN DIMENSIONS > ENVIRONMENTAL IMPACTSEARTH SCIENCE > HUMAN DIMENSIONS > ENVIRONMENTAL IMPACTSEARTH SCIENCE > HUMAN DIMENSIONS > ENVIRONMENTAL IMPACTSEARTH SCIENCE > HUMAN DIMENSIONS > ENVIRONMENTAL IMPACTSEARTH SCIENCE > HUMAN DIMENSIONS > HUMAN HEALTHEARTH SCIENCE > HUMAN DIMENSIONS > HUMAN HEALTHEARTH SCIENCE > HUMAN DIMENSIONS > HUMAN HEALTHEARTH SCIENCE > HUMAN DIMENSIONS > HUMAN HEALTHEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > GROUND WATEREARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > LAND SURFACE > EROSION/SEDIMENTATIONEARTH SCIENCE > LAND SURFACE > EROSION/SEDIMENTATIONEARTH SCIENCE > LAND SURFACE > LAND USE/LAND COVEREARTH SCIENCE > LAND SURFACE > SOILSEARTH SCIENCE > SOLID EARTH > NATURAL RESOURCESEARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > AIR QUALITYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC CHEMISTRYEARTH SCIENCE > BIOLOGICAL CLASSIFICATION > ANIMALS/VERTEBRATESEARTH SCIENCE > BIOLOGICAL CLASSIFICATION > ANIMALS/VERTEBRATESEARTH SCIENCE > BIOSPHERE > ECOLOGICAL DYNAMICSEARTH SCIENCE > BIOSPHERE > VEGETATIONEARTH SCIENCE > HUMAN DIMENSIONS > HABITAT CONVERSION/FRAGMENTATIONEARTH SCIENCE > HUMAN DIMENSIONS > ENVIRONMENTAL IMPACTSEARTH SCIENCE > HUMAN DIMENSIONS > ENVIRONMENTAL IMPACTSEARTH SCIENCE > HUMAN DIMENSIONS > ENVIRONMENTAL IMPACTSEARTH SCIENCE > HUMAN DIMENSIONS > ENVIRONMENTAL IMPACTSEARTH SCIENCE > HUMAN DIMENSIONS > HUMAN HEALTHEARTH SCIENCE > HUMAN DIMENSIONS > HUMAN HEALTHEARTH SCIENCE > HUMAN DIMENSIONS > HUMAN HEALTHEARTH SCIENCE > HUMAN DIMENSIONS > HUMAN HEALTHEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > GROUND WATEREARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > TERRESTRIAL HYDROSPHERE > WATER QUALITY/WATER CHEMISTRYEARTH SCIENCE > LAND SURFACE > EROSION/SEDIMENTATIONEARTH SCIENCE > LAND SURFACE > EROSION/SEDIMENTATIONEARTH SCIENCE > LAND SURFACE > LAND USE/LAND COVEREARTH SCIENCE > LAND SURFACE > SOILSEARTH SCIENCE > SOLID EARTH > NATURAL RESOURCES'
   },
   {
     title: 'should grab the correct dataset_url link',
     xpath: "/doc/field[@name='dataset_url']",
     expected_text: 'http://sedac.ciesin.columbia.edu/data/set/esi-pilot-environmental-sustainability-index-2000'
   },
   {
     title: 'should grab the correct updated date',
     xpath: "/doc/field[@name='last_revision_date']",
     expected_text: '2008-12-02T00:00:00Z'
   },
   {
     title: 'should grab the correct spatial display bounds',
     xpath: "/doc/field[@name='spatial_coverages'][1]",
     expected_text: '-55 -180 90 180'
   },
   {
     title: 'should grab the correct spatial bounds',
     xpath: "/doc/field[@name='spatial'][1]",
     expected_text: '-180 -55 180 90'
   },
   {
     title: 'should calculate the correct spatial area',
     xpath: "/doc/field[@name='spatial_area'][1]",
     expected_text: '145.0'
   },
   {
    title: 'should grab the correct temporal coverage',
    xpath: "/doc/field[@name='temporal_coverages'][1]",
    expected_text: '1984-12-25T00:00:00Z,1988-03-04T00:00:00Z'
   },
   {
     title: 'should grab the correct temporal duration',
     xpath: "/doc/field[@name='temporal_duration'][1]",
     expected_text: '8035'
   },
   {
     title: 'should grab the correct temporal range',
     xpath: "/doc/field[@name='temporal'][1]",
     expected_text: '19.841225 19.880304'
   },
   {
     title: 'should grab the correct source',
     xpath: "/doc/field[@name='source']",
     expected_text: 'ADE'
   },
   {
     title: 'should grab the correct spatial facet',
     xpath: "/doc/field[@name='facet_spatial_coverage'][1]",
     expected_text: 'Non Global'
   },
   {
     title: 'should grab the correct spatial scope facet',
     xpath: "/doc/field[@name='facet_spatial_scope'][1]",
     expected_text: 'Between 1 and 170 degrees of latitude change | Regional'
   }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end
  puts "\n\n==============\n"
end
