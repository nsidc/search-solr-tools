# The hash contains keys that should map to the fields in the solr schema, the keys are called selectors
# and are in charge of selecting the nodes from the ISO document, applying the default value if none of the
# xpaths resolved to a value and formatting the field.
# xpaths and multivalue are required, default_value and format are optional

NODC = {
  authoritative_id: {
      xpaths: [''],
      multivalue: false
    },
  title: {
      xpaths: [''],
      multivalue: false
    },
  summary: {
      xpaths: [''],
      multivalue: false
    },
  data_centers: {
      xpaths: [''],
      multivalue: false
    },
  authors: {
      xpaths: [''],
      multivalue: true
    },
  keywords: {
      xpaths: [''],
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
      xpaths: [''],
      multivalue: false
    },
  dataset_url: {
      xpaths: [''],
      multivalue: false
    },
  source: {
      xpaths: [''],
      default_value: ['ADE'],
      multivalue: false
    },
}
