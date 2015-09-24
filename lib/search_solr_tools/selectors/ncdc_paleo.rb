require 'search_solr_tools'

module SearchSolrTools
  module Selectors
    NCDC_PALEO = {
      title: {
        xpaths: ['/rdf:RDF/rdf:Description/dc:title'],
        multivalue: false
      },
      summary: {
        xpaths: ['/rdf:RDF/rdf:Description/dc:description'],
        multivalue: false
      },
      data_centers: {
        xpaths: [''],
        default_values: [Helpers::SolrFormat::DATA_CENTER_NAMES[:NCDC_PALEO][:long_name]],
        multivalue: false
      },
      authors: {
        xpaths: ['/rdf:RDF/rdf:Description/dc:creator'],
        multivalue: true,
        format: Helpers::NcdcPaleoFormat.method(:author)
      },
      keywords: {
        xpaths: ['/rdf:RDF/rdf:Description/dc:subject'],
        multivalue: true
      },
      last_revision_date: {
        xpaths: ['/rdf:RDF/rdf:Description/dc:date'],
        default_values: [''], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
        multivalue: false,
        format: Helpers::SolrFormat::DATE
      },
      spatial_coverages: {
        xpaths: ['/rdf:RDF/rdf:Description/ows:WGS84BoundingBox'],
        multivalue: true,
        format: Helpers::NcdcPaleoFormat.method(:spatial_display_str)
      },
      spatial: {
        xpaths: ['/rdf:RDF/rdf:Description/ows:WGS84BoundingBox'],
        multivalue: true,
        format: Helpers::NcdcPaleoFormat.method(:spatial_index_str)
      },
      spatial_area: {
        xpaths: ['/rdf:RDF/rdf:Description/ows:WGS84BoundingBox'],
        multivalue: false,
        reduce: Helpers::NcdcPaleoFormat.method(:get_max_spatial_area),
        format: Helpers::NcdcPaleoFormat.method(:spatial_area_str)
      },
      temporal: {
        xpaths: ['/rdf:RDF/rdf:Description/dc:coverage'],
        multivalue: true,
        format: Helpers::NcdcPaleoFormat.method(:temporal_index_str)
      },
      temporal_coverages: {
        xpaths: ['/rdf:RDF/rdf:Description/dc:coverage'],
        multivalue: true,
        format: Helpers::NcdcPaleoFormat.method(:temporal_display_str)
      },
      temporal_duration: {
        xpaths: ['/rdf:RDF/rdf:Description/dc:coverage'],
        multivalue: false,
        reduce: Helpers::SolrFormat::REDUCE_TEMPORAL_DURATION,
        format: Helpers::NcdcPaleoFormat.method(:get_temporal_duration)
      },
      source: {
        xpaths: [''],
        default_values: ['ADE'],
        multivalue: false
      },
      facet_data_center: {
        xpaths: [''],
        default_values: ["#{Helpers::SolrFormat::DATA_CENTER_NAMES[:NCDC_PALEO][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:NCDC_PALEO][:short_name]}"],
        multivalue: false
      },
      facet_spatial_scope: {
        xpaths: ['/rdf:RDF/rdf:Description/ows:WGS84BoundingBox'],
        multivalue: true,
        format: Helpers::NcdcPaleoFormat.method(:get_spatial_scope_facet)
      },
      facet_temporal_duration: {
        xpaths: ['/rdf:RDF/rdf:Description/dc:coverage'],
        default_values: [Helpers::SolrFormat::NOT_SPECIFIED],
        format: Helpers::NcdcPaleoFormat.method(:get_temporal_duration_facet),
        multivalue: true
      }
    }
  end
end
