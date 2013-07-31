require 'guard'

namespace :guard do
  desc 'Automatically run RuboCop'
  task :rubocop do
    sh 'bundle exec guard -P rubocop -i'
  end

  desc 'Automatically run unit tests'
  task :specs do
    sh 'bundle exec guard -P rspec -i'
  end
end

desc 'Activate all guards'
task :guard do
  sh 'bundle exec guard -i'
end
