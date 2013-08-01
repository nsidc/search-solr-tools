# The hash contains keys that should map to the fields in the solr schema, the keys are called selectors
# and are in charge of selecting the nodes from the ISO document, applying the default value if none of the
# xpaths resolved to a value and formatting the field.
# xpaths and multivalue are required, default_value and format are optional.
require './lib/selectors/iso_to_solr_format'

CISL = {
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
      xpaths: ['.//gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString'],
      default_values: ['Advanced Cooperative Arctic Data and Information Service'],
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
  topics: {
      xpaths: [''],
      multivalue: true
    },
  parameters: {
      xpaths: [''],
      multivalue: false
    },
  platforms: {
      xpaths: [''],
      multivalue: false
    },
  sensors: {
      xpaths: [''],
      multivalue: true
    },
  last_revision_date: {
      xpaths: ['//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date', '//gmd:dateStamp'],
      default_values: [IsoToSolrFormat.date_str(DateTime.now)], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
      multivalue: false,
      format: IsoToSolrFormat::DATE
    },
  dataset_url: {
      xpaths: ['.//gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL'],
      multivalue: false
    },
  source: {
      xpaths: [''],
      default_values: ['ADE'],
      multivalue: false
    },
}