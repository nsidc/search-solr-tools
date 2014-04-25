require 'fileutils'
require './lib/build_subs.rb'
require File.join('.', 'config', 'environments.rb')

# All tasks are defined within specific rake files within the tasks directory
Dir.glob('./tasks/*.rake').each { |r| import r }
