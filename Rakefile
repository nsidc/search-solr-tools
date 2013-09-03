require 'fileutils'
require './lib/build_subs.rb'
require File.join('.', 'config', 'environments.rb')

Dir.glob('./tasks/*.rake').each { |r| import r }

desc 'Run server:stop, rake build:setup, server:start, harvest:delete_all, harvest:nsidc_oai_iso in one task'
task restart_with_clean_nsidc_harvest: ['server:stop', 'build:setup', 'server:start'] do
  puts 'Sleeping 5 seconds for server to start'
  sleep(5)
  Rake::Task['harvest:delete_all'].invoke
  Rake::Task['harvest:nsidc_oai_iso'].invoke
end
