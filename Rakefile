require 'fileutils'
require 'rubocop/rake_task'

# All tasks are defined within specific rake files within the tasks directory
Dir.glob('./tasks/*.rake').each { |r| import r }

RuboCop::RakeTask.new

desc 'Run RuboCop and RSpec code examples'
task :default do
  failure = false

  %w(rubocop spec:unit).each do |task_name|
    sh "rake #{task_name}" do |ok, _res|
      failure = !ok
    end
  end

  exit failure ? 1 : 0
end
