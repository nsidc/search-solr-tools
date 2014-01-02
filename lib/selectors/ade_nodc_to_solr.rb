require './lib/selectors/iso_to_solr_format'

# The hash contains keys that should map to the fields in the solr schema, the keys are called selectors
# and are in charge of selecting the nodes from the ISO document, applying the default value if none of the
# xpaths resolved to a value and formatting the field.
# xpaths and multivalue are required, default_value and format are optional

NODC = {
  authoritative_id: {
    xpaths: ['.//gmd:fileIdentifier/gco:CharacterString'],
    multivalue: false
  },
  title: {
    xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString'],
    multivalue: false
  },
  summary: {
    xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString'],
    multivalue: false
  },
  data_centers: {
    xpaths: ['.//gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString'],
    default_values: ['NOAA National Oceanographic Data Center'],
    multivalue: false
  },
  authors: {
    xpaths: [".//gmd:CI_ResponsibleParty[./gmd:role/gmd:CI_RoleCode[@codeListValue='principalInvestigator']]/gmd:individualName/gco:CharacterString"],
    multivalue: true
  },
  keywords: {
    xpaths: ['.//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString',
             './/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmx:Anchor'],
    multivalue: true
  },
  last_revision_date: {
    xpaths: ['.//gmd:dateStamp/gco:Date'],
    multivalue: false,
    format: IsoToSolrFormat::DATE
  },
  dataset_url: {
    xpaths: ['.//gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[./gmd:protocol/gco:CharacterString/text()="ftp"]/gmd:linkage/gmd:URL'],
    multivalue: false
  },
  spatial_coverages: {
      xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
      multivalue: true,
      format: IsoToSolrFormat::SPATIAL_DISPLAY
  },
  spatial: {
      xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
      multivalue: true,
      format: IsoToSolrFormat::SPATIAL_INDEX
  },
  temporal_coverages: {
    xpaths: ['.//gmd:EX_TemporalExtent'],
    multivalue: true,
    format: proc { |node| IsoToSolrFormat.temporal_display_str(node, true) }
  },
  temporal: {
    xpaths: ['.//gmd:EX_TemporalExtent'],
    multivalue: true,
    format: proc { |node| IsoToSolrFormat.temporal_index_str node }
  },
  sensors: {
    xpaths: ['.//gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/gmi:MI_Instrument/gmi:citation/gmd:CI_Citation/gmd:title/gco:CharacterString'],
    multivalue: true
  },
  source: {
    xpaths: [''],
    default_values: ['ADE'],
    multivalue: false
  },
  facet_data_center: {
      xpaths: [''],
      default_values: ['NOAA National Oceanographic Data Center'],
      multivalue: false
  },
  facet_spatial_coverage: {
      xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
      multivalue: true,
      format: IsoToSolrFormat::FACET_SPATIAL_COVERAGE
  },
  facet_temporal_duration: {
    xpaths: ['.//gmd:EX_TemporalExtent'],
    format: IsoToSolrFormat::FACET_TEMPORAL_DURATION,
    multivalue: true
  },
  facet_author: {
    xpaths: [".//gmd:CI_ResponsibleParty[./gmd:role/gmd:CI_RoleCode[@codeListValue='principalInvestigator']]/gmd:individualName/gco:CharacterString"],
    multivalue: true,
    unique: true
  }
}
