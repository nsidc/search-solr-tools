require_relative './search_solr_tools/config/environments'
require_relative './search_solr_tools/version'

require File.join(__dir__, 'search_solr_tools', 'harvesters', 'base.rb')
%w( helpers selectors harvesters translators ).each do |subdir|
  puts File.join(__dir__, 'search_solr_tools', subdir)
  Dir[File.join(__dir__, 'search_solr_tools', subdir, '*.rb')]
      .reject{ |f| f.include? 'selectors.rb'}
      .each do |file|
    puts file
    require file
  end
end
require File.join(__dir__, 'search_solr_tools', 'helpers', 'selectors.rb')
