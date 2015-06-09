require 'search_solr_tools/helpers'

module SearchSolrTools
  module Selectors
    # The hash contains keys that should map to the fields in the solr schema,
    # the keys are called selectors and are in charge of selecting the nodes
    # from the ISO document, applying the default value if none of the xpaths
    # resolved to a value and formatting the field.  xpaths and multivalue are
    # required, default_value and format are optional.
    EOL = {
      authoritative_id: {
        xpaths: ['.//gmd:fileIdentifier/gco:CharacterString'],
        multivalue: false,
        format: proc do |node| # double equals in the ID is "breaking" the harvest in liquid/qa etc.
          node.text.split('==')[0] || ''
        end
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
        default_values: [Helpers::SolrFormat::DATA_CENTER_NAMES[:EOL][:long_name]],
        multivalue: false
      },
      authors: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty'],
        multivalue: true,
        unique: true,
        format: Helpers::IsoToSolrFormat::EOL_AUTHOR_FORMAT
      },
      keywords: {
        xpaths: ['.//gmd:keyword/gco:CharacterString'],
        multivalue: true
      },
      last_revision_date: {
        xpaths: ['.//gmd:dateStamp/gco:Date', '//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date'],
        default_values: [Helpers::SolrFormat.date_str(DateTime.now)], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
        multivalue: false,
        format: Helpers::SolrFormat::DATE
      },
      dataset_url: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:supplementalInformation/gco:CharacterString'],
        multivalue: false,
        format: proc do |node|
          matches = node.text.match('http://data.eol.ucar.edu/codiac/dss/id=(\S*)')
          matches ? matches[0] : ''
        end
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
        xpaths: ['.//gmd:EX_TemporalExtent'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::TEMPORAL_DISPLAY_STRING
      },
      temporal: {
        xpaths: ['.//gmd:EX_TemporalExtent'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::TEMPORAL_INDEX_STRING
      },
      temporal_duration: {
        xpaths: ['.//gmd:EX_TemporalExtent'],
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
        default_values: ["#{Helpers::SolrFormat::DATA_CENTER_NAMES[:EOL][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:EOL][:short_name]}"],
        multivalue: false
      },
      facet_spatial_scope: {
        xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox'],
        multivalue: true,
        format: Helpers::IsoToSolrFormat::FACET_SPATIAL_SCOPE
      },
      facet_temporal_duration: {
        xpaths: ['.//gmd:EX_TemporalExtent'],
        default_values: [Helpers::SolrFormat::NOT_SPECIFIED],
        format: Helpers::IsoToSolrFormat::FACET_TEMPORAL_DURATION,
        multivalue: true
      }
    }
  end
end
