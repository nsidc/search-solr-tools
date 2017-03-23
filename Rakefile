require 'fileutils'
require 'rubocop/rake_task'

# All tasks are defined within specific rake files within the tasks directory
Dir.glob('./tasks/*.rake').each { |r| import r }

RuboCop::RakeTask.new

desc 'Run RuboCop and RSpec code examples'
task :default do
  results_ok = %w(rubocop spec:unit).map do |task_name|
    sh "rake #{task_name}" do |ok, _res|
      ok
    end
  end

  exit results_ok.all? ? 0 : 1
end
