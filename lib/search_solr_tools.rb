require_relative 'search_solr_tools/config/environments'
require_relative 'search_solr_tools/version'

require_relative 'search_solr_tools/helpers/selectors'
%w( selectors harvesters translators ).each do |subdir|
  Dir[File.join(__dir__, 'search_solr_tools', subdir, '*.rb')].each { |file| require file }
end
