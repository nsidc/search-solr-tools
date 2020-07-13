require_relative 'iso_namespaces'
require_relative 'iso_to_solr_format'
require_relative 'solr_format'

module SearchSolrTools
  module Helpers
    class DataOneFormat < IsoToSolrFormat
      class << self
        def date_range(node)
          {
            start: SolrFormat.date_str(node.xpath('.//date[@name="beginDate"]').text.strip),
            end: SolrFormat.date_str(node.xpath('.//date[@name="endDate"]').text.strip)
          }
        end

        def bounding_box(node)
          {
            north: node.xpath('.//float[@name="northBoundCoord"]').text.strip,
            south: node.xpath('.//float[@name="southBoundCoord"]').text.strip,
            east: node.xpath('.//float[@name="eastBoundCoord"]').text.strip,
            west: node.xpath('.//float[@name="westBoundCoord"]').text.strip
          }
        end

        def spatial_display(node)
          box = bounding_box(node)

          [box[:south], box[:west], box[:north], box[:east]].join(' ')
        end

        def spatial_index(node)
          box = bounding_box(node)

          if box[:west] == box[:east] && box[:south] == box[:north]
            [box[:west], box[:south]]
          else
            [box[:west], box[:south], box[:east], box[:north]]
          end.join(' ')
        end

        def spatial_area(node)
          box = bounding_box(node)

          box[:north].to_f - box[:south].to_f
        end

        def temporal_coverage(node)
          SolrFormat.temporal_display_str(date_range(node))
        end

        def temporal_duration(node)
          dr = date_range(node)
          end_time = dr[:end].to_s.empty? ? Time.now : Time.parse(dr[:end])
          SolrFormat.get_temporal_duration(Time.parse(dr[:start]), end_time) unless dr[:start].to_s.empty?
        end

        def temporal_index_string(node)
          dr = date_range(node)
          SolrFormat.temporal_index_str(dr)
        end

        def facet_spatial_scope(node)
          box = bounding_box(node)
          SolrFormat.get_spatial_scope_facet_with_bounding_box(box)
        end

        def facet_temporal_duration(node)
          duration = temporal_duration(node)
          SolrFormat.get_temporal_duration_facet(duration)
        end
      end
    end
  end
end
