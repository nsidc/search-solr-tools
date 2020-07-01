require_relative '../helpers/solr_format'
require_relative '../helpers/iso_to_solr_format'
require_relative '../helpers/r2r_format'

module SearchSolrTools
  module Selectors
    # The hash contains keys that should map to the fields in the solr schema,
    # the keys are called selectors and are in charge of selecting the nodes
    # from the ISO document, applying the default value if none of the xpaths
    # resolved to a value and formatting the field.  xpaths and multivalue are
    # required, default_value, format, and reduce are optional.
    #
    # reduce takes the formatted result of multiple nodes and produces a single
    #   result. This is for fields that are not multivalued, but their value
    #   should consider information from all the nodes (for example, storing
    #   only the maximum duration from multiple temporal coverage fields, taking
    #   the sum of multiple spatial areas)
    R2R = {
      authoritative_id: {
        xpaths: ['.//gmd:fileIdentifier/gco:CharacterString'],
        multivalue: false
      },
      title: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gmx:Anchor'],
        multivalue: false
      },
      summary: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString'],
        multivalue: false
      },
      data_centers: {
        xpaths: [''],
        default_values: [Helpers::SolrFormat::DATA_CENTER_NAMES[:R2R][:long_name]],
        multivalue: false
      },
      authors: {
        xpaths: [".//gmd:CI_ResponsibleParty[./gmd:role/gmd:CI_RoleCode[@codeListValue='contributor']]/gmd:individualName/gmx:Anchor"],
        multivalue: true
      },
      keywords: {
        xpaths: ['.//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString',
                 './/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmx:Anchor'],
        multivalue: true
      },
      last_revision_date: {
        xpaths: ['.//gmd:dateStamp/gco:Date', './/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:DateTime'],
        default_values: [Helpers::SolrFormat.date_str(DateTime.now)], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
        multivalue: false,
        format: Helpers::SolrFormat::DATE
      },
      dataset_url: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href'],
        multivalue: false,
        format: Helpers::IsoToSolrFormat::DATASET_URL
      },
      spatial_coverages: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::SPATIAL_DISPLAY
      },
      spatial: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::SPATIAL_INDEX
      },
      spatial_area: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
        multivalue: false,
        reduce: Helpers::IsoToSolrFormat::MAX_SPATIAL_AREA,
        format: Helpers::IsoToSolrFormat::SPATIAL_AREA
      },
      temporal_coverages: {
        xpaths: ['.//gmd:EX_Extent[@id="temporalExtent"]'],
        multivalue: false,
        format: Helpers::R2RFormat::TEMPORAL_DISPLAY_STRING
      },
      temporal_duration: {
        xpaths: ['.//gmd:EX_Extent[@id="temporalExtent"]'],
        multivalue: false,
        reduce: Helpers::SolrFormat::REDUCE_TEMPORAL_DURATION,
        format: Helpers::R2RFormat::TEMPORAL_DURATION
      },
      temporal: {
        xpaths: ['.//gmd:EX_Extent[@id="temporalExtent"]'],
        multivalue: false,
        format: Helpers::R2RFormat::TEMPORAL_INDEX_STRING
      },
      sensors: {
        xpaths: ['.//gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/gmi:MI_Instrument/gmi:type/gmx:Anchor'],
        multivalue: true
      },
      source: {
        xpaths: [''],
        default_values: ['ADE'],
        multivalue: false
      },
      facet_data_center: {
        xpaths: [''],
        default_values: ["#{Helpers::SolrFormat::DATA_CENTER_NAMES[:R2R][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:R2R][:short_name]}"],
        multivalue: false
      },
      facet_spatial_scope: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::FACET_SPATIAL_SCOPE
      },
      facet_temporal_duration: {
        xpaths: ['.//gmd:EX_Extent[@id="temporalExtent"]'],
        default_values: [Helpers::SolrFormat::NOT_SPECIFIED],
        format: Helpers::R2RFormat::FACET_TEMPORAL_DURATION,
        multivalue: true
      }
    }
  end
end
