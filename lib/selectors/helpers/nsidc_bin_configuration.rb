require 'rest_client'
require 'json'

module FacetConfiguration
  class BinConfiguration
    def initialize
      @bin_configuration = JSON.parse(RestClient.get(SolrEnvironments[@environments][:nsidc_dataset_metadata_url] + '/binConfiguration'))
    end

    def GetFacetBin(facet_name)
      @bin_configuration.select{|x| x['facet_name'] == facet_name}.sort_by!{|x| x['order_value']}
    end
  end
end
