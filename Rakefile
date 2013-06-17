require 'fileutils'
require 'rspec/core/rake_task'
require './lib/build_subs.rb'
require File.join('.', 'config', 'environments.rb')

Dir.glob('./tasks/*.rake').each { |r| import r }

namespace :spec do
  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.pattern = './spec/*{.feature}'
  end
end

