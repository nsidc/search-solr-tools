require_relative '../helpers/solr_format'
require_relative '../helpers/iso_to_solr_format'
require_relative '../helpers/usgs_format'

module SearchSolrTools
  module Selectors
    # The hash contains keys that should map to the fields in the solr schema,
    # the keys are called selectors and are in charge of selecting the nodes
    # from the ISO document, applying the default value if none of the xpaths
    # resolved to a value and formatting the field. xpaths and multivalue are
    # required, default_value and format are optional
    USGS = {
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
        default_values: [Helpers::SolrFormat::DATA_CENTER_NAMES[:USGS][:long_name]],
        multivalue: false
      },
      authors: {
        xpaths: [".//gmd:contact/gmd:CI_ResponsibleParty[./gmd:role/gmd:CI_RoleCode[@codeListValue='originator']]/gmd:organisationName/gco:CharacterString"],
        multivalue: true
      },
      keywords: {
        xpaths: ['.//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString'],
        multivalue: true
      },
      last_revision_date: {
        xpaths: ['.//gmd:dateStamp/gco:DateTime'],
        default_values: [Helpers::SolrFormat.date_str(DateTime.now)], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
        multivalue: false,
        format: Helpers::SolrFormat::DATE
      },
      dataset_url: {
        xpaths: ['.//gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[contains(./gmd:name/gco:CharacterString/text(),"Summary")]/gmd:linkage/gmd:URL'],
        multivalue: false
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
      temporal: {
        xpaths: [".//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[./gmd:dateType/gmd:CI_DateTypeCode[@codeListValue='Time Period']]/gmd:date"],
        multivalue: true,
        format: Helpers::UsgsFormat::TEMPORAL_INDEX_STRING
      },
      temporal_coverages: {
        xpaths: [".//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[./gmd:dateType/gmd:CI_DateTypeCode[@codeListValue='Time Period']]/gmd:date"],
        multivalue: true,
        format: Helpers::UsgsFormat::TEMPORAL_DISPLAY_STRING
      },
      temporal_duration: {
        xpaths: [".//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[./gmd:dateType/gmd:CI_DateTypeCode[@codeListValue='Time Period']]/gmd:date"],
        multivalue: false,
        reduce: Helpers::SolrFormat::REDUCE_TEMPORAL_DURATION,
        format: Helpers::UsgsFormat::TEMPORAL_DURATION
      },
      sensors: {
        xpaths: [''],
        multivalue: true
      },
      source: {
        xpaths: [''],
        default_values: ['ADE'],
        multivalue: false
      },
      facet_data_center: {
        xpaths: [''],
        default_values: ["#{Helpers::SolrFormat::DATA_CENTER_NAMES[:USGS][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:USGS][:short_name]}"],
        multivalue: false
      },
      facet_spatial_scope: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::FACET_SPATIAL_SCOPE
      },
      facet_temporal_duration: {
        xpaths: [".//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[./gmd:dateType/gmd:CI_DateTypeCode[@codeListValue='Time Period']]/gmd:date"],
        default_values: [Helpers::SolrFormat::NOT_SPECIFIED],
        format: Helpers::UsgsFormat::FACET_TEMPORAL_DURATION,
        multivalue: true
      }
    }
  end
end
