require_relative './iso_namespaces'
require_relative './iso_to_solr_format'

module SearchSolrTools
  module Helpers
    # Special formatter for dealing with temporal metadata issues in the USGS feed
    class UsgsFormat < IsoToSolrFormat
      TEMPORAL_INDEX_STRING = proc { |node| UsgsFormat.temporal_index_str(node) }
      TEMPORAL_DISPLAY_STRING = proc { |node| UsgsFormat.temporal_display_str(node) }
      TEMPORAL_DURATION = proc { |node| UsgsFormat.get_temporal_duration(node) }
      FACET_TEMPORAL_DURATION = proc { |node| UsgsFormat.get_temporal_duration_facet(node) }

      # for USGS, a single date entry (i.e., missing either start or end date, and
      # the value that is present is not clearly labeled) means the whole year if
      # just a year is given, or just a single day if just a single day is given
      def self.date_range(temporal_node, formatted = false)
        xpath = './/gco:Date'
        namespaces = IsoNamespaces.namespaces(temporal_node)

        temporal_node_count = temporal_node.xpath(xpath, namespaces).size
        date_str = temporal_node.at_xpath(xpath, namespaces).text

        super if temporal_node_count != 1

        case date_str
        when /^[0-9]{4}$/
          year_to_range(date_str)
        when /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/
          single_date_to_range(date_str)
        else
          super
        end
      end

      def self.single_date_to_range(date)
        {
          start: date,
          end: date
        }
      end

      def self.year_to_range(year)
        {
          start: "#{year}-01-01",
          end: "#{year}-12-31"
        }
      end
    end
  end
end
