require_relative '../helpers/solr_format'
require_relative '../helpers/iso_to_solr_format'

module SearchSolrTools
  module Selectors
    # The hash contains keys that should map to the fields in the solr schema,
    # the keys are called selectors and are in charge of selecting the nodes
    # from the ISO document, applying the default value if none of the xpaths
    # resolved to a value and formatting the field. xpaths and multivalue are
    # required, default_value, format, and reduce are optional.
    #
    # reduce takes the formatted result of multiple nodes and produces a single
    #   result. This is for fields that are not multivalued, but their value
    #   should consider information from all the nodes (for example, storing
    #   only the maximum duration from multiple temporal coverage fields, taking
    #   the sum of multiple spatial areas)
    PDC = {
      authoritative_id: {
        xpaths: ['.//oai:header/oai:identifier'],
        multivalue: false
      },
      title: {
        xpaths: ['.//gmd:citation//gmd:title/gco:CharacterString'],
        multivalue: false
      },
      summary: {
        xpaths: ['.//gmd:abstract/gco:CharacterString'],
        multivalue: false
      },
      data_centers: {
        xpaths: [''],
        default_values: [Helpers::SolrFormat::DATA_CENTER_NAMES[:PDC][:long_name]],
        multivalue: false
      },
      authors: {
        xpaths: ['.//gmd:identificationInfo//gmd:citedResponsibleParty//gmd:individualName/gco:CharacterString'],
        multivalue: true
      },
      keywords: {
        xpaths: ['.//gmd:descriptiveKeywords//gmd:keyword/gco:CharacterString'],
        multivalue: true
      },
      last_revision_date: {
        xpaths: ['.//oai:header/oai:datestamp'],
        default_values: [Helpers::SolrFormat.date_str(DateTime.now)], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
        multivalue: false,
        format: Helpers::SolrFormat::DATE
      },
      dataset_url: {
        xpaths: ['.//gmd:dataSetURI/gco:CharacterString'],
        multivalue: false,
        format: Helpers::SolrFormat::HTTP_URL_FORMAT
      },
      spatial_coverages: {
        xpaths: ['.//gmd:extent//gmd:EX_GeographicBoundingBox'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::SPATIAL_DISPLAY
      },
      spatial: {
        xpaths: ['.//gmd:extent//gmd:EX_GeographicBoundingBox'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::SPATIAL_INDEX
      },
      spatial_area: {
        xpaths: ['.//gmd:extent//gmd:EX_GeographicBoundingBox'],
        multivalue: false,
        reduce: Helpers::IsoToSolrFormat::MAX_SPATIAL_AREA,
        format: Helpers::IsoToSolrFormat::SPATIAL_AREA
      },
      temporal: {
        xpaths: ['.//gmd:EX_TemporalExtent/gmd:extent'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::TEMPORAL_INDEX_STRING
      },
      temporal_coverages: {
        xpaths: ['.//gmd:EX_TemporalExtent/gmd:extent'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::TEMPORAL_DISPLAY_STRING
      },
      temporal_duration: {
        xpaths: ['.//gmd:EX_TemporalExtent/gmd:extent'],
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
        default_values: ["#{Helpers::SolrFormat::DATA_CENTER_NAMES[:PDC][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:PDC][:short_name]}"],
        multivalue: false
      },
      facet_spatial_scope: {
        xpaths: ['.//gmd:extent//gmd:EX_GeographicBoundingBox'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::FACET_SPATIAL_SCOPE
      },
      facet_temporal_duration: {
        xpaths: ['.//gmd:EX_TemporalExtent/gmd:extent'],
        default_values: [Helpers::SolrFormat::NOT_SPECIFIED],
        format: Helpers::IsoToSolrFormat::FACET_TEMPORAL_DURATION,
        multivalue: true
      }
    }
  end
end
