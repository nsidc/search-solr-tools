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
      xpaths: [''],
      default_values: ['NOAA National Oceanographic Data Center'],
      multivalue: false
  },
  authors: {
    xpaths: ['.//gmd:CI_ResponsibleParty[.//gmd:CI_RoleCode="resourceProvider"]//gmd:individualName'],
    multivalue: true,
    unique: true
  },
  keywords: {
    xpaths: ['.//gmd:MD_Keywords[.//gmd:MD_KeywordTypeCode="theme" and not(.//gmd:thesaurusName)]//gmd:keyword/gco:CharacterString'],
    multivalue: true
  },
  sensors: {
    xpaths: ['.//gmi:MI_Instrument/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString'],
    multivalue: true
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
    format: proc { |node| IsoToSolrFormat.temporal_display_str node }
  },
  temporal_duration: {
    xpaths: ['.//gmd:EX_TemporalExtent'],
    multivalue: false,
    reduce: IsoToSolrFormat::REDUCE_TEMPORAL_DURATION,
    format: IsoToSolrFormat::TEMPORAL_DURATION
  },
  temporal: {
    xpaths: ['.//gmd:EX_TemporalExtent'],
    multivalue: true,
    format: proc { |node| IsoToSolrFormat.temporal_index_str node }
  },
  last_revision_date: {
    xpaths: ['.//gmd:dateStamp/gco:Date'],
    multivalue: false,
    format: IsoToSolrFormat::DATE
  },
  source: {
    xpaths: [''],
    default_values: %w(ADE),
    multivalue: true
  },
  facet_data_center: {
      xpaths: [''],
      default_values: ['NOAA National Oceanographic Data Center | NOAA NODC'],
      multivalue: true
  },
  facet_spatial_coverage: {
    xpaths: ['.//gmd:EX_GeographicBoundingBox'],
    multivalue: true,
    format: IsoToSolrFormat::FACET_SPATIAL_COVERAGE
  },
  facet_temporal_duration: {
    xpaths: ['.//gmd:EX_TemporalExtent'],
    default_values: ['No Temporal Information'],
    format: IsoToSolrFormat::FACET_TEMPORAL_DURATION,
    multivalue: true
  },
  facet_author: {
    xpaths: ['.//gmd:CI_ResponsibleParty[.//gmd:CI_RoleCode="principalInvestigator"]//gmd:individualName[not(contains(gco:CharacterString, "NSIDC User Services"))]
              | .//gmd:CI_ResponsibleParty[.//gmd:CI_RoleCode="author"]//gmd:individualName[not(contains(gco:CharacterString, "NSIDC User Services"))]
              | .//gmd:CI_ResponsibleParty[.//gmd:CI_RoleCode="metadata author"]//gmd:individualName[not(contains(gco:CharacterString, "NSIDC User Services"))]'],
    multivalue: true,
    unique: true
  }
}
