require 'selectors/helpers/iso_to_solr'

describe 'PDC ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/unit/fixtures/pdc_oai.xml')
  iso_to_solr = IsoToSolr.new(:pdc)
  solr_doc = iso_to_solr.translate fixture

  test_expectations = [
    {
      title: 'should include the correct authoritative id',
      xpath: "/doc/field[@name='authoritative_id']",
      expected_text: '80_iso'
    },
    {
      title: 'should grab the correct title',
      xpath: "/doc/field[@name='title']",
      expected_text: 'ArcticNet 0501a - Northern Baffin Bay CTD data'
    },
    {
      title: 'should grab the correct summary',
      xpath: "/doc/field[@name='summary']",
      expected_text: %(The CTD data was obtained during the 2005 ArcticNet scientific cruise #0501. The data were collected from August 14 to 23, 2005, aboard the CCGS Amundsen. There were 54 casts, associated to 36 oceanographic stations, in the Northern Baffin Bay. The following parameters were measured: temperature, conductivity and pressure (with a Sea-Bird SBE-9plus), dissolved oxygen (Sea-Bird SBE-43), pH (Sea-Bird SBE-18-I), fluorescence (Seapoint chlorophyll fluorometer), nitrate concentration (Satlantic MBARI-ISUS 5T), transmittance (Wetlabs C-Star transmissometer), light intensity (PAR; Biospherical Instruments QCP2300) and surface light intensity (sPAR; Biospherical Instruments QCP2200). Quality control procedures were applied to the data. Data are available on the Polar Data Catalogue and at the Marine Environmental Data Service (MEDS) of Fisheries and Oceans Canada.)
    },
    {
      title: 'should grab the correct data center',
      xpath: "/doc/field[@name='data_centers']",
      expected_text: 'Polar Data Catalog'
    },
    {
      title: 'should grab the correct author',
      xpath: "/doc/field[@name='authors']",
      expected_text: 'Gratton YvesGratton YvesLago VroniqueRail Marie-Emmanuelle'
    },
    {
      title: 'should grab the correct keywords',
      xpath: "/doc/field[@name='keywords']",
      expected_text: 'North Water PolynyaCTD profilesOxygenSalinityTemperaturePhotosynthetically available radiation (PAR)FluorescenceNitratesTransmittanceNorthern Baffin Bay, Nunavut'
    },
    {
      title: 'should grab the correct updated date',
      xpath: "/doc/field[@name='last_revision_date']",
      expected_text: '2014-11-24T19:34:39Z'
    },
    {
      title: 'should grab the correct get data link',
      xpath: "/doc/field[@name='dataset_url']",
      expected_text: 'http://www.polardata.ca/pdcsearch/PDCSearchDOI.jsp?doi_id=80'
    },
    {
      title: 'should grab the correct spatial display bounds',
      xpath: "/doc/field[@name='spatial_coverages']",
      expected_text: '72 -80 79 -70'
    },
    {
      title: 'should grab the correct spatial bounds',
      xpath: "/doc/field[@name='spatial']",
      expected_text: '-80 72 -70 79'
    },
    {
      title: 'should calculate the correct spatial area',
      xpath: "/doc/field[@name='spatial_area']",
      expected_text: '7.0'
    },
    {
      title: 'should grab the correct temporal coverage',
      xpath: "/doc/field[@name='temporal_coverages']",
      expected_text: '2005-08-14,2005-08-23'
    },
    {
      title: 'should grab the correct temporal range',
      xpath: "/doc/field[@name='temporal']",
      expected_text: '20.050814 20.050823'
    },
    {
      title: 'should calculate the correct temporal duration',
      xpath: "/doc/field[@name='temporal_duration']",
      expected_text: '10'
    },
    {
      title: 'should grab the correct source',
      xpath: "/doc/field[@name='source']",
      expected_text: 'ADE'
    },
    {
      title: 'should grab the correct data center facet',
      xpath: "/doc/field[@name='facet_data_center']",
      expected_text: 'Polar Data Catalog | PDC'
    },
    {
      title: 'should grab the correct spatial scope facet',
      xpath: "/doc/field[@name='facet_spatial_scope']",
      expected_text: 'Between 1 and 170 degrees of latitude change | Regional'
    },
    {
      title: 'should grab the correct temporal duration facet',
      xpath: "/doc/field[@name='facet_temporal_duration']",
      expected_text: '< 1 year'
    }
  ]

  test_expectations.each do |expectation|
    it expectation[:title] do
      solr_doc.xpath(expectation[:xpath]).text.strip.should eql expectation[:expected_text]
    end
  end
end
