require './lib/selectors/iso_to_solr_format'

# The hash contains keys that should map to the fields in the solr schema, the keys are called selectors
# and are in charge of selecting the nodes from the ISO document, applying the default value if none of the
# xpaths resolved to a value and formatting the field.
# xpaths and multivalue are required, default_value and format are optional.

EOL = {
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
      default_values: ['UCAR/NCAR - Earth Observing Laboratory/Computing, Data and Software Facility'],
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
  dataset_url: {
      xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:supplementalInformation/gco:CharacterString'],
      multivalue: false,
      format: proc { |str| str.match('http://data.eol.ucar.edu/codiac/dss/id=(.)')[0] }
    },
  source: {
      xpaths: [''],
      default_values: ['ADE'],
      multivalue: false
    },
}
