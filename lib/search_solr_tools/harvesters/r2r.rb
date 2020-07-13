require_relative 'base'

require 'nokogiri'
require 'rest-client'

module SearchSolrTools
  module Harvesters
    class R2R < Base
      def initialize(env = 'development', die_on_failure = false)
        super
        @data_centers = Helpers::SolrFormat::DATA_CENTER_NAMES[:R2R][:long_name]
        @translator = Helpers::IsoToSolr.new :r2r
        @metadata_url = SolrEnvironments[@environment][:r2r_url]
      end

      def harvest_and_delete
        puts "Running #{self.class.name} at #{@metadata_url}"
        super(method(:harvest), %(data_centers:"#{@data_centers}"))
      end

      # rubocop: disable MethodLength
      # rubocop: disable AbcSize
      def harvest
        # first fetch list of available records at http://get.rvdata.us/services/cruise/
        # then loop through each one of those, using the root <gmi:MI_Metadata> tag
        puts "Getting list of records from #{@data_centers}"
        RestClient.get(@metadata_url) do |resp, _req, _result, &_block|
          unless resp.code == 200
            puts "Got code #{resp.code} from #{@metadata_url}, skipping R2R harvest."
            next
          end

          doc = Nokogiri::HTML(resp.body)

          urls = doc.xpath('//a').map do |node|
            "#{@metadata_url}#{node.attr('href')}"
          end

          urls.each_slice(50) do |url_subset|
            # each result is a nokogirii doc with root element
            # <gmi:MI_Metadata>
            results = url_subset.map do |url|
              get_results(url, '//gmi:MI_Metadata').first
            end

            begin
              translated = results.map do |e|
                create_new_solr_add_doc_with_child(@translator.translate(e).root)
              end

              insert_solr_docs(translated)
            rescue => e
              puts "ERROR: #{e}"
              raise e if @die_on_failure
            end
          end
        end
      end
    end
  end
end
