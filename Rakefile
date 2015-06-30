require 'fileutils'
require 'rubocop/rake_task'

# All tasks are defined within specific rake files within the tasks directory
Dir.glob('./tasks/*.rake').each { |r| import r }

RuboCop::RakeTask.new

desc 'Run RuboCop and RSpec code examples'
task default: %w(rubocop spec:unit)
