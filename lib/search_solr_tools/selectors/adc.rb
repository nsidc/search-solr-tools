require_relative '../helpers/solr_format'
require_relative '../helpers/data_one_format'

module SearchSolrTools
  module Selectors
    ADC = {
      authoritative_id: {
        xpaths: ['.//str[@name="id"]'],
        multivalue: false
      },
      title: {
        xpaths: ['.//str[@name="title"]'],
        multivalue: false
      },
      summary: {
        xpaths: ['.//str[@name="abstract"]'],
        multivalue: false
      },
      data_centers: {
        xpaths: [''],
        default_values: [Helpers::SolrFormat::DATA_CENTER_NAMES[:ADC][:long_name]],
        multivalue: false
      },
      authors: {
        xpaths: ['.//str[@name="author"]'],
        multivalue: false
      },
      keywords: {
        xpaths: ['.//arr[@name="keywords"]/str'],
        multivalue: true
      },
      last_revision_date: {
        xpaths: ['.//date[@name="updateDate"]'],
        default_values: [Helpers::SolrFormat.date_str(DateTime.now)], # formats the date into ISO8601 as in http://lucene.apache.org/solr/4_4_0/solr-core/org/apache/solr/schema/DateField.html
        multivalue: false,
        format: Helpers::SolrFormat::DATE
      },
      dataset_url: {
        xpaths: ['.//str[@name="dataUrl"]'],
        default_values: [''],
        multivalue: false
      },
      spatial_coverages: {
        xpaths: ['.'],
        multivalue: false,
        format: Helpers::DataOneFormat.method(:spatial_display)
      },
      spatial: {
        xpaths: ['.'],
        multivalue: false,
        format: Helpers::DataOneFormat.method(:spatial_index)
      },
      spatial_area: {
        xpaths: ['.'],
        multivalue: false,
        format: Helpers::DataOneFormat.method(:spatial_area)
      },
      temporal_coverages: {
        xpaths: ['.'],
        multivalue: false,
        format: Helpers::DataOneFormat.method(:temporal_coverage)
      },
      temporal_duration: {
        xpaths: ['.'],
        multivalue: false,
        format: Helpers::DataOneFormat.method(:temporal_duration)
      },
      temporal: {
        xpaths: ['.'],
        multivalue: false,
        format: Helpers::DataOneFormat.method(:temporal_index_string)
      },
      source: {
        xpaths: [''],
        default_values: ['ADE'],
        multivalue: false
      },
      facet_data_center: {
        xpaths: [''],
        default_values: ["#{Helpers::SolrFormat::DATA_CENTER_NAMES[:ADC][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:ADC][:short_name]}"],
        multivalue: false
      },
      facet_spatial_scope: {
        xpaths: ['.'],
        multivalue: false,
        format: Helpers::DataOneFormat.method(:facet_spatial_scope)
      },
      facet_temporal_duration: {
        xpaths: ['.'],
        default_values: [Helpers::SolrFormat::NOT_SPECIFIED],
        format: Helpers::DataOneFormat.method(:facet_temporal_duration),
        multivalue: false
      }
    }
  end
end
