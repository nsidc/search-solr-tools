require 'fileutils'
require 'rspec/core/rake_task'
require './lib/build_subs.rb'
require './config/environments'

SOLR_START_JAR = 'start.jar'
SOLR_PID_FILE = 'solr.pid'

Dir.glob('./tasks/*.rake').each { |r| import r }

namespace :spec do
  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.pattern = './spec/*{.feature}'
  end
end

