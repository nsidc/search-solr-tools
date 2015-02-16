require 'fileutils'
require File.join('.', 'config', 'environments.rb')

# All tasks are defined within specific rake files within the tasks directory
Dir.glob('./tasks/*.rake').each { |r| import r }

desc 'Run bumpversion'
task :bump, [:part] do |t, args|
  version_filename = 'metadata.json'
  version = JSON.load(File.new(version_filename))['version']

  cmd = "bumpversion --current-version #{version} #{args[:part]} #{version_filename}"
  exec cmd
end
