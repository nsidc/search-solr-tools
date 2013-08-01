require './lib/selectors/iso_to_solr_format'

# The hash contains keys that should map to the fields in the solr schema, the keys are called selectors
# and are in charge of selecting the nodes from the ISO document, applying the default value if none of the
# xpaths resolved to a value and formatting the field.
# xpaths and multivalue are required, default_value and format are optional
require './lib/selectors/iso_to_solr_format'

NSIDC = {
  authoritative_id: {
    xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString'],
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
  authors: {
    xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty[.//gmd:CI_RoleCode="principalInvestigator"]//gmd:individualName/gco:CharacterString'],
    multivalue: true
  },
  topics: {
    xpaths: ['.//gmd:MD_TopicCategoryCode'],
    multivalue: true
  },
  keywords: {
    xpaths: ['.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="theme" and not(.//gmd:thesaurusName)]//gmd:keyword/gco:CharacterString'],
    multivalue: true
  },
  parameters: {
    xpaths: ['.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="discipline"]//gmd:keyword/gco:CharacterString'],
    multivalue: true,
    format: proc { |param| param.split ' > ' }
  },
  full_parameters: {
    xpaths: ['.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="discipline"]//gmd:keyword/gco:CharacterString'],
    multivalue: true
  },
  platforms: {
    xpaths: ['.//gmi:MI_Platform/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString'],
    multivalue: true
  },
  sensors: {
    xpaths: ['.//gmi:MI_Instrument/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString'],
    multivalue: true
  },
  brokered: {
    xpaths: ['count(.//gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[gmd:CI_OnLineFunctionCode="offlineAccess"])'],
    multivalue: false,
    format: proc { |count| counts > 0 ? 'true' : 'false' }
  },
  published_date: {
    xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date'],
    multivalue: false,
    format: IsoToSolrFormat::DATE
  },
  spatial_coverages: {
    xpaths: ['.//gmd:EX_GeographicBoundingBox'],
    multivalue: true,
    format: proc { |node| IsoToSolrFormat.spatial_display_str node }
  },
  spatial: {
    xpaths: ['.//gmd:EX_GeographicBoundingBox'],
    multivalue: true,
    format: IsoToSolrFormat::SPATIAL_INDEX
  },
  temporal_coverages: {
    xpaths: ['.//gmd:EX_TemporalExtent'],
    multivalue: true,
    format: proc { |node| IsoToSolrFormate.temporal_display_str node }
  },
  temporal_index: {
    xpaths: ['.//gmd:EX_TemporalExtent'],
    multivalue: true,
    format: proc { |node| IsoToSolrFormate.temporal_index_str node }
  },
  last_revision_date: {
    xpaths: ['.//gmd:dateStamp/gco:Date'],
    multivalue: false
  },
  dataset_url: {
    xpaths: ['.//gmd:dataSetURI'],
    multivalue: false
  },
  data_access_urls: {
    xpaths: ['.//gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[gmd:CI_OnLineFunctionCode="download"]//gmd:URL'],
    multivalue: true
  },
  distribution_formats: {
    xpaths: ['.//gmd:MD_Format/gmd:name/gco:CharacterString'],
    multivalue: true
  },
  source: {
    xpaths: [''],
    default_value: %w(NSIDC ADE),
    multivalue: true
  },
}
