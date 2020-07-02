require_relative '../helpers/solr_format'
require_relative '../helpers/iso_to_solr_format'

module SearchSolrTools
  module Selectors
    # The hash contains keys that should map to the fields in the solr schema,
    # the keys are called selectors and are in charge of selecting the nodes
    # from the ISO document, applying the default value if none of the xpaths
    # resolved to a value and formatting the field. xpaths and multivalue are
    # required, default_value and format are optional
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
        default_values: [Helpers::SolrFormat::DATA_CENTER_NAMES[:ECHO][:long_name]],
        multivalue: false
      },
      authors: {
        xpaths: [''],
        multivalue: true
      },
      keywords: {
        xpaths: ['.//Collection/ScienceKeywords/ScienceKeyword'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::KEYWORDS
      },
      last_revision_date: {
        xpaths: ['.//Collection/LastUpdate'],
        default_values: [Helpers::SolrFormat.date_str(DateTime.now)], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
        multivalue: false,
        format: Helpers::SolrFormat::DATE
      },
      dataset_url: {
        xpaths: ['.//Collection/OnlineResources/OnlineResource[contains(./Type/text(),"static URL")]/URL',
                 './/Collection/OnlineResources/OnlineResource[contains(./Type/text(), "VIEW RELATED INFORMATION")]/URL',
                 './/Collection/OnlineAccessURLs/OnlineAccessURL/[contains(./URLDescription/text(), "Data Access")]/URL',
                 './/Collection/OnlineResources/OnlineResource[contains(./Type/text(),"Guide Document for this product at NSIDC")]/URL',
                 './/Collection/OnlineResources/OnlineResource[contains(./Type/text(),"DOI URL")]/URL',
                 './/Collection/OnlineResources/OnlineResource[contains(./Type/text(),"ECSCollGuide")]/URL',
                 './/Collection/OnlineResources/OnlineResource[contains(./Type/text(),"GET DATA : ON-LINE ARCHIVE")]/URL',
                 './/Collection/OnlineResources/OnlineResource/URL',
                 './/Collection/OnlineAccessURLs/OnlineAccessURL/URL'],
        default_values: ['https://earthdata.nasa.gov/echo'],
        multivalue: false
      },
      spatial_coverages: {
        xpaths: ['.//Collection/Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::SPATIAL_DISPLAY
      },
      spatial: {
        xpaths: ['.//Collection/Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::SPATIAL_INDEX
      },
      spatial_area: {
        xpaths: ['.//Collection/Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'],
        multivalue: false,
        reduce: Helpers::IsoToSolrFormat::MAX_SPATIAL_AREA,
        format: Helpers::IsoToSolrFormat::SPATIAL_AREA
      },
      temporal_coverages: {
        xpaths: ['.//Collection/Temporal/RangeDateTime'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::TEMPORAL_DISPLAY_STRING_FORMATTED
      },
      temporal_duration: {
        xpaths: ['.//Collection/Temporal/RangeDateTime'],
        multivalue: false,
        reduce: Helpers::SolrFormat::REDUCE_TEMPORAL_DURATION,
        format: Helpers::IsoToSolrFormat::TEMPORAL_DURATION
      },
      temporal: {
        xpaths: ['.//Collection/Temporal/RangeDateTime'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::TEMPORAL_INDEX_STRING
      },
      source: {
        xpaths: [''],
        default_values: ['ADE'],
        multivalue: false
      },
      facet_data_center: {
        xpaths: [''],
        default_values: ["#{Helpers::SolrFormat::DATA_CENTER_NAMES[:ECHO][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:ECHO][:short_name]}"],
        multivalue: false
      },
      facet_spatial_scope: {
        xpaths: ['.//Collection/Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::FACET_SPATIAL_SCOPE
      },
      facet_temporal_duration: {
        xpaths: ['.//Collection/Temporal/RangeDateTime'],
        default_values: [Helpers::SolrFormat::NOT_SPECIFIED],
        format: Helpers::IsoToSolrFormat::FACET_TEMPORAL_DURATION,
        multivalue: true
      }
    }
  end
end
