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
      default_value: DateTime.now.iso8601[0..-7] + 'Z', # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
      multivalue: false,
      format: proc { |date| [DateTime.parse(date[0].squeeze(' ').strip).iso8601[0..-7] + 'Z'] }
    },
  dataset_url: {
      xpaths: ['.//gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL'],
      multivalue: false
    },
  source: {
      xpaths: [''],
      default_value: 'ADE',
      multivalue: false
    },
}