require 'json'
require 'nokogiri'
require 'webmock/rspec'

require 'search_solr_tools'
require 'search_solr_tools/helpers/solr_format'
require 'search_solr_tools/helpers/harvest_status'

GZIP_DEFLATE_IDENTITY = 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'