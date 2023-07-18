require_relative 'search_solr_tools/config/environments'
require_relative 'search_solr_tools/version'

require_relative 'search_solr_tools/helpers/harvest_status'
require_relative 'search_solr_tools/errors/harvest_error'

%w( harvesters translators ).each do |subdir|
  Dir[File.join(__dir__, 'search_solr_tools', subdir, '*.rb')].each { |file| require file }
end
