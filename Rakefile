require 'fileutils'
require 'rspec/core/rake_task'
require './lib/build_subs.rb'
require File.join('.', 'config', 'environments.rb')

Dir.glob('./tasks/*.rake').each { |r| import r }

namespace :spec do
  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.rspec_opts = %w[-f progress -f JUnit -o results.xml]
    t.pattern = './spec/*{.feature}'
  end

  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = './spec/**/*{_spec.rb}'
  end
end

