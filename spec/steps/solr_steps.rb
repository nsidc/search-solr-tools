require File.join('.', 'config', 'environments.rb')
require File.join('page_objects', 'solr_search_page')

# module to control solr in acceptance tests
module SolrSteps
  step 'I am using the current environment settings' do
    @target_env = ENV['TARGET_ENVIRONMENT'] || 'development'
    @environment = SolrEnvironments[@target_env]
  end

  step 'I search for :terms' do |terms|
    @page = SolrSearchPage.new(@environment[:host], @environment[:port], @environment[:collection_path], @environment[:collection_name])
    @page.query terms
  end

  step 'I should get a valid response with results' do
    @page.is_valid?.should be true
    @page.total_results.should be > 0
    @page.results.size.should be <= @page.total_results
  end
end

RSpec.configure { |c| c.include SolrSteps }
