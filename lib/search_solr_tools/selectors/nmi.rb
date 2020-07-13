require_relative '../helpers/solr_format'
require_relative '../helpers/iso_to_solr_format'

module SearchSolrTools
  module Selectors
    # The hash contains keys that should map to the fields in the solr schema,
    # the keys are called selectors and are in charge of selecting the nodes
    # from the ISO document, applying the default value if none of the xpaths
    # resolved to a value and formatting the field.  xpaths and multivalue are
    # required, default_value and format are optional.
    NMI = {
      authoritative_id: {
        xpaths: ['.//oai:header/oai:identifier'],
        multivalue: false
      },
      title: {
        xpaths: ['.//dif:Entry_Title'],
        multivalue: false
      },
      summary: {
        xpaths: ['.//dif:Summary'],
        multivalue: false
      },
      data_centers: {
        xpaths: [''],
        default_values: [Helpers::SolrFormat::DATA_CENTER_NAMES[:NMI][:long_name]],
        multivalue: false
      },
      authors: {
        xpaths: [''],
        multivalue: true
      },
      keywords: {
        xpaths: [
          './/dif:Parameters/dif:Category',
          './/dif:Parameters/dif:Topic',
          './/dif:Parameters/dif:Term',
          './/dif:Parameters/dif:Variable_Level_1'
        ].reverse,
        multivalue: true
      },
      last_revision_date: {
        xpaths: ['.//dif:Last_DIF_Revision_Date'],
        default_values: [Helpers::SolrFormat.date_str(DateTime.now)], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
        multivalue: false,
        format: Helpers::SolrFormat::DATE
      },
      dataset_url: {
        xpaths: ['.//dif:Related_URL/dif:URL'],
        multivalue: false
      },
      spatial_coverages: {
        xpaths: ['.//dif:Spatial_Coverage'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::SPATIAL_DISPLAY
      },
      spatial: {
        xpaths: ['.//dif:Spatial_Coverage'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::SPATIAL_INDEX
      },
      spatial_area: {
        xpaths: ['.//dif:Spatial_Coverage'],
        multivalue: false,
        reduce: Helpers::IsoToSolrFormat::MAX_SPATIAL_AREA,
        format: Helpers::IsoToSolrFormat::SPATIAL_AREA
      },
      temporal: {
        xpaths: ['.//dif:Temporal_Coverage'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::TEMPORAL_INDEX_STRING
      },
      temporal_coverages: {
        xpaths: ['.//dif:Temporal_Coverage'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::TEMPORAL_DISPLAY_STRING
      },
      temporal_duration: {
        xpaths: ['.//dif:Temporal_Coverage'],
        multivalue: false,
        reduce: Helpers::SolrFormat::REDUCE_TEMPORAL_DURATION,
        format: Helpers::IsoToSolrFormat::TEMPORAL_DURATION
      },
      source: {
        xpaths: [''],
        default_values: ['ADE'],
        multivalue: false
      },
      facet_data_center: {
        xpaths: [''],
        default_values: ["#{Helpers::SolrFormat::DATA_CENTER_NAMES[:NMI][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:NMI][:short_name]}"],
        multivalue: false
      },
      facet_spatial_scope: {
        xpaths: ['.//dif:Spatial_Coverage'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::FACET_SPATIAL_SCOPE
      },
      facet_temporal_duration: {
        xpaths: ['.//dif:Temporal_Coverage'],
        default_values: [Helpers::SolrFormat::NOT_SPECIFIED],
        format: Helpers::IsoToSolrFormat::FACET_TEMPORAL_DURATION,
        multivalue: true
      }
    }
  end
end
