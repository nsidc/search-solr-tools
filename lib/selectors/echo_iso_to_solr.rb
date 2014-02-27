require './lib/selectors/iso_to_solr_format'

# The hash contains keys that should map to the fields in the solr schema, the keys are called selectors
# and are in charge of selecting the nodes from the ISO document, applying the default value if none of the
# xpaths resolved to a value and formatting the field.
# xpaths and multivalue are required, default_value and format are optional

long_name = 'NASA Earth Observing System (EOS) Clearing House (ECHO)'
short_name = 'NASA ECHO'

ECHO = {
  authoritative_id: {
    xpaths: ['.//@echo_dataset_id'],
    multivalue: false
  },
  title: {
    xpaths: ['.//Collection/LongName'],
    multivalue: false
  },
  summary: {
    xpaths: ['.//Collection/Description'],
    multivalue: false
  },
  data_centers: {
    xpaths: [''],
    default_values: [long_name],
    multivalue: false
  },
  authors: {
    xpaths: [''],
    multivalue: true
  },
  keywords: {
    xpaths: ['.//Collection/ScienceKeywords/ScienceKeyword'],
    multivalue: true,
    format: IsoToSolrFormat::KEYWORDS
  },
  last_revision_date: {
    xpaths: ['.//Collection/LastUpdate'],
    multivalue: false,
    format: IsoToSolrFormat::DATE
  },
  dataset_url: {
    xpaths: [".//Collection/OnlineResources/OnlineResource[contains(./Description/text(),'data set homepage')]/URL"],
    multivalue: false
  },
  spatial_coverages: {
    xpaths: ['.//Collection/Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'],
    multivalue: true,
    format: IsoToSolrFormat::SPATIAL_DISPLAY
  },
  spatial: {
    xpaths: ['.//Collection/Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'],
    multivalue: true,
    format: IsoToSolrFormat::SPATIAL_INDEX
  },
  spatial_area: {
    xpaths: ['.//Collection/Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'],
    multivalue: false,
    reduce: IsoToSolrFormat::TOTAL_SPATIAL_AREA,
    format: IsoToSolrFormat::SPATIAL_AREA
  },
  temporal_coverages: {
    xpaths: ['.//Collection/Temporal/RangeDateTime'],
    multivalue: true,
    format: proc { |node| IsoToSolrFormat.temporal_display_str(node, true) }
  },
  temporal_duration: {
    xpaths: ['.//Collection/Temporal/RangeDateTime'],
    multivalue: false,
    reduce: IsoToSolrFormat::REDUCE_TEMPORAL_DURATION,
    format: IsoToSolrFormat::TEMPORAL_DURATION
  },
  temporal: {
    xpaths: ['.//Collection/Temporal/RangeDateTime'],
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
    xpaths: ['.//Collection/Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'],
    multivalue: true,
    format: IsoToSolrFormat::FACET_SPATIAL_COVERAGE
  },
  facet_spatial_scope: {
    xpaths: ['.//Collection/Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'],
    multivalue: true,
    format: IsoToSolrFormat::FACET_SPATIAL_SCOPE
  },
  facet_temporal_duration: {
    xpaths: ['.//Collection/Temporal/RangeDateTime'],
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
