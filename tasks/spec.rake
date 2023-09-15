# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    ENV['SOLR_HARVEST_LOG_FILE'] ||= 'none'
    ENV['SOLR_HARVEST_STDOUT_LEVEL'] ||= 'fatal'
    t.pattern = './spec/unit/**/*{_spec.rb}'
  end
end
