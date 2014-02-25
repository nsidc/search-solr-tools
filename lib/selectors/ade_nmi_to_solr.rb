require './lib/selectors/iso_to_solr_format'

# The hash contains keys that should map to the fields in the solr schema, the keys are called selectors
# and are in charge of selecting the nodes from the ISO document, applying the default value if none of the
# xpaths resolved to a value and formatting the field.
# xpaths and multivalue are required, default_value and format are optional

long_name = 'Norwegian Meteorological Institute'
short_name = 'Met.no'

NMI = {
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
      xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString'],
      default_values: [long_name],
      multivalue: false
  },
  authors: {
      xpaths: [''],
      multivalue: true
  },
  keywords: {
      xpaths: ['.//gmd:keyword/gco:CharacterString'],
      multivalue: true
  },
  last_revision_date: {
      xpaths: ['//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date', '//gmd:dateStamp'],
      default_values: [IsoToSolrFormat.date_str(DateTime.now)], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
      multivalue: false,
      format: IsoToSolrFormat::DATE
  },
  spatial_coverages: {
      xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
      multivalue: true,
      format: proc { |node| IsoToSolrFormat.spatial_display_str node }
  },
  spatial: {
      xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
      multivalue: true,
      format: IsoToSolrFormat::SPATIAL_INDEX
  },
  spatial_area: {
    xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
    multivalue: false,
    reduce: IsoToSolrFormat::TOTAL_SPATIAL_AREA,
    format: IsoToSolrFormat::SPATIAL_AREA
  },
  dataset_url: {
      xpaths: ['.//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL'],
      multivalue: false
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
  source: {
      xpaths: [''],
      default_values: ['ADE'],
      multivalue: false
  },
  facet_data_center: {
      xpaths: [''],
      default_values: ["#{long_name} | #{short_name}"],
      multivalue: false
  },
  facet_spatial_coverage: {
      xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
      multivalue: true,
      format: IsoToSolrFormat::FACET_SPATIAL_COVERAGE
  },
  facet_spatial_scope: {
    xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
    multivalue: true,
    format: IsoToSolrFormat::FACET_SPATIAL_SCOPE
  },
  facet_temporal_duration: {
    xpaths: ['.//gmd:EX_TemporalExtent'],
    default_values: ['No Temporal Information'],
    format: IsoToSolrFormat::FACET_TEMPORAL_DURATION,
    multivalue: true
  },
  facet_author: {
    xpaths: [''],
    multivalue: true,
    unique: true
  }
}
