require 'date'

require_relative 'iso_namespaces'
require_relative 'solr_format'
require_relative 'iso_to_solr_format'

module SearchSolrTools
  module Helpers
    class NcdcPaleoFormat < IsoToSolrFormat
      def self.bounding_box(node)
        east, north = node.xpath('./ows:UpperCorner').text.split
        west, south = node.xpath('./ows:LowerCorner').text.split
        { north: north, south: south, east: east, west: west }
      end

      def self.date_range(node, _formatted = false)
        if node.text.include?('START YEAR')
          if node.text.include?('AD')
            format_ad_time(node.text)
          elsif node.text.include?('yr BP')
            format_cal_yr_bp_time(node.text)
          end
        end
      end

      def self.format_ad_time(node_text)
        match = node_text.match(/START YEAR:(?<start>[^*]*)AD\s*\* END YEAR:(?<end>[^*]*)AD/)
        {
          start: DateTime.strptime(match[:start].strip, '%Y'),
          end: DateTime.strptime(match[:end].strip, '%Y')
        }
      end

      def self.format_cal_yr_bp_time(node_text)
        zero_year = 1950
        match = node_text.match(/START YEAR:(?<start>[^*]*)... yr BP\s*\* END YEAR:(?<end>[^*]*)... yr BP/)
        {
          start: DateTime.strptime((-(match[:start].strip.to_i) - zero_year).to_s, '%Y'),
          end: DateTime.strptime((-(match[:end].strip.to_i) - zero_year).to_s, '%Y')
        }
      end

      def self.temporal_index_str(node)
        range = date_range(node)
        SolrFormat.temporal_index_str(start: range[:start].to_s, end: range[:end].to_s) unless range.nil?
      end

      def self.get_temporal_duration(node)
        range = date_range(node)
        return if range.to_s.empty?
        (range[:start] - range[:end]).to_i.abs
      end

      def self.author(node)
        return node if node == ''
        return if node.text.include? ';'
        node.text
      end
    end
  end
end
