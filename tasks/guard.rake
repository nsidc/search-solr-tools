require 'guard'

namespace :guard do
  desc 'Automatically run RuboCop'
  task :rubocop do
    sh 'bundle exec guard -P rubocop'
  end

  desc 'Automatically run unit tests'
  task :specs do
    sh 'bundle exec guard -P rspec'
  end
end

desc 'Activate all guards'
task :guard do
  sh 'bundle exec guard'
end
