require_relative 'iso_namespaces'
require_relative 'iso_to_solr_format'
require_relative 'solr_format'

module SearchSolrTools
  module Helpers
    class R2RFormat < IsoToSolrFormat
      TEMPORAL_INDEX_STRING = proc { |node| R2RFormat.temporal_index_str(node) }
      TEMPORAL_DISPLAY_STRING = proc { |node| R2RFormat.temporal_display_str(node) }
      TEMPORAL_DURATION = proc { |node| R2RFormat.get_temporal_duration(node) }
      FACET_TEMPORAL_DURATION = proc { |node| R2RFormat.get_temporal_duration_facet(node) }

      def self.date_range(temporal_node, _formatted = false)
        xpath_start = './/gmd:temporalElement/gmd:EX_SpatialTemporalExtent/gmd:extent/'\
                      'gml:TimeInstant[@gml:id="start"]/gml:timePosition'
        xpath_end = xpath_start.gsub('start', 'end')

        {
          start: temporal_node.xpath(xpath_start).text,
          end:   temporal_node.xpath(xpath_end).text
        }
      end
    end
  end
end
