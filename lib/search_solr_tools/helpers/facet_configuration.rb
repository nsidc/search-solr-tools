# frozen_string_literal: true

require 'json'
require 'rest_client'
require 'singleton'

module SearchSolrTools
  module Helpers
    ## Singleton configuration class to get and parse the binning configuration from the catalog services endpoint
    class FacetConfiguration
      include Singleton

      def self.import_bin_configuration(env)
        if @bin_configuration.nil?
          @bin_configuration = JSON.parse(
            RestClient::Request.execute(method: :get, url: "#{SolrEnvironments[env][:nsidc_dataset_metadata_url]}binConfiguration", verify_ssl: OpenSSL::SSL::VERIFY_NONE)
          )
        end
      end

      def self.get_facet_bin(facet_name)
        @bin_configuration.select { |x| x['facet_name'] == facet_name }.sort_by! { |x| x['order_value'] }
      end
    end
  end
end
