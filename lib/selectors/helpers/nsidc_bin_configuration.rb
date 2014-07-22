require 'rest_client'
require 'json'
require 'singleton'

## Singleton configuration class to get and parse the binning configuration from the catalog services endpoint
class FacetConfiguration
  include Singleton
  def self.import_bin_configuration
    @bin_configuration = JSON.parse(RestClient.get(SolrEnvironments[@environments][:nsidc_dataset_metadata_url] + '/binConfiguration')) if @bin_configuration.nil?
  end

  def self.get_facet_bin(facet_name)
    @bin_configuration.select { |x| x['facet_name'] == facet_name }.sort_by! { |x| x['order_value'] }
  end
end
