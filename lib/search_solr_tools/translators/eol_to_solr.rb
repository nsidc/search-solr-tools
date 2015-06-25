module SearchSolrTools
  module Translators
    # Translates an EOL THREDDS dataset link set into a SOLR json ingest record
    class EolToSolr
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength

      def translate(title_metadata, dataset_metadata)
        temporal_coverage_values = Helpers::TranslateTemporalCoverage.translate_coverages get_time_coverages(dataset_metadata)
        rev_date = dataset_metadata.xpath('//xmlns:date[@type="metadataCreated"]').text
        geospatial_coverage = parse_geospatial_coverages(dataset_metadata)
        {
          'title' => title_metadata.xpath('//xmlns:dataset').first['name'],
          'authoritative_id' => title_metadata.xpath('//xmlns:dataset').first['ID'],
          'data_centers' => Helpers::SolrFormat::DATA_CENTER_NAMES[:EOL][:long_name],
          'facet_data_center' => "#{Helpers::SolrFormat::DATA_CENTER_NAMES[:EOL][:long_name]} | #{Helpers::SolrFormat::DATA_CENTER_NAMES[:EOL][:short_name]}",
          'summary' => dataset_metadata.xpath('//xmlns:documentation[@type="summary"]').text,
          'temporal_coverages' => temporal_coverage_values['temporal_coverages'],
          'temporal_duration' => temporal_coverage_values['temporal_duration'],
          'temporal' => temporal_coverage_values['temporal'],
          'facet_temporal_duration' => temporal_coverage_values['facet_temporal_duration'],
          'last_revision_date' => rev_date.empty? ? Helpers::SolrFormat.date_str(DateTime.now) : Helpers::SolrFormat.date_str(rev_date),
          'source' => 'ADE',
          'keywords' => dataset_metadata.xpath('//xmlns:keyword').map(&:text),
          'authors' => dataset_metadata.xpath('//xmlns:contributor[@role="author"]').map { |node| parse_eol_authors(node.text) }.join(', '),
          'dataset_url' => eol_dataset_url(dataset_metadata),
          'facet_spatial_coverage' => Helpers::BoundingBoxUtil.box_global?(geospatial_coverage),
          'facet_spatial_scope' => Helpers::SolrFormat.get_spatial_scope_facet_with_bounding_box(geospatial_coverage),
          'spatial_coverages' => %i(south west north east).map { |d| geospatial_coverage[d] }.join(' '),
          'spatial_area' => spatial_coverage_to_spatial_area(geospatial_coverage),
          'spatial' => %i(west south east north).map { |d| geospatial_coverage[d] }.join(' ')
        }
      end

      def eol_dataset_url(node)
        begin
          node.xpath('//xmlns:documentation[@xlink:href]').each do |doc|
            return doc['xlink:href'] if doc['xlink:href'].match('http://data.eol.ucar.edu/codiac/dss/id=(\S*)')
          end
        rescue Nokogiri::XML::XPath::SyntaxError
          puts "Warning - no documentation URL found in the following node: #{node.to_html}"
          return nil
        end
        nil
      end

      def parse_eol_authors(author)
        if author.include?(' AT ') && author.include?(' dot ')
          author = author[0..author.rindex(',') - 1]
        end
        author
      end

      def get_time_coverages(doc)
        doc.xpath('//xmlns:timeCoverage').map do |node|
          { 'start' => node.xpath('./xmlns:start').text, 'end' => node.xpath('./xmlns:end').text }
        end
      end

      def spatial_coverage_to_spatial_area(coverage)
        return if [:north, :south].any? { |x| coverage[x].nil? }
        coverage[:north].abs - coverage[:south].abs
      end

      def parse_geospatial_coverages(doc)
        node = doc.xpath('//xmlns:geospatialCoverage')
        south = node.xpath('./xmlns:northsouth/xmlns:start').text.to_f
        north = south + (node.xpath('./xmlns:northsouth/xmlns:size').text.to_f)
        west = node.xpath('./xmlns:eastwest/xmlns:start').text.to_f
        east = west + (node.xpath('./xmlns:eastwest/xmlns:size').text.to_f)
        # EOL uses out-of-range east-west values to represent bounding boxes
        # that cross the date line.   For any box with a value out of range,
        # adjust the east/west value to lie within the -180 to 180 range.
        east -= 360 if east > 180
        west += 360 if west < -180

        { east: east, west: west, north: north, south: south }
      end
    end
  end
end
