require 'json'
require 'nokogiri'
require 'webmock/rspec'

require 'search_solr_tools'

GZIP_DEFLATE_IDENTITY = 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'