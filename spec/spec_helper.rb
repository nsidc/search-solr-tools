require 'json'
require 'nokogiri'
require 'webmock/rspec'

require 'search_solr_tools'
require 'search_solr_tools/helpers/solr_format'
require 'search_solr_tools/helpers/harvest_status'

GZIP_DEFLATE_IDENTITY = 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'

# TODO: This is used to allow use of the `stub_chain` in `harvester_base_spec`.
# We may consider removing `stub_chain` and using a different approach instead.
RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end