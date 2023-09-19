# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    ENV['SEARCH_SOLR_LOG_FILE'] ||= 'none'
    ENV['SEARCH_SOLR_STDOUT_LEVEL'] ||= 'fatal'
    t.pattern = './spec/unit/**/*{_spec.rb}'
  end
end
