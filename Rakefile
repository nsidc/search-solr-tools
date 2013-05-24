require 'fileutils'

SOLR_ENVIRONMENTS = {
    :local => {
      :install_dir => '/opt/solr/dev',
      :conf_dir => 'solr/collection1/conf'
    }
}

SOLR_START_JAR = 'start.jar'
SOLR_PID_FILE = 'solr.pid'

task :update_index, :environemnt do |t, args|
  copy_index_file args
end

task :start_solr, :environemnt do |t, args|
  copy_index_file args

  env = SOLR_ENVIRONMENTS[args[:environemnt].to_sym]
  pid_file = pid_path env
  stop(pid_file)

  pid = fork do
    Process.setsid
    STDIN.reopen('/dev/null')
    STDOUT.reopen('/dev/null')
    STDERR.reopen(STDOUT)
    run env
  end
  sh "sudo sh -c \"echo '#{pid}' > #{pid_file}\""
end

task :stop_solr, :environemnt do |t, args|
  env = SOLR_ENVIRONMENTS[args[:environemnt].to_sym]
  pid_file = pid_path env

  if !stop(pid_file)
    raise "No PID file at #{pid_file}"
  end
end

def copy_index_file(args)
  env = SOLR_ENVIRONMENTS[args[:environemnt].to_sym]
  sh "sudo cp schema.xml #{env[:install_dir]}/#{env[:conf_dir]}"
end

def run(env)
  exec "cd #{env[:install_dir]}; sudo java -jar #{SOLR_START_JAR}"
end

def stop(pid_file)
  if File.exist?(pid_file)
    pid = IO.read(pid_file).to_i

    begin
      sh "sudo kill -15 -#{pid}"
      true
    rescue
      raise "Process with PID #{pid} is no longer running"
    ensure
      sh "sudo rm #{pid_file}"
    end
  else
    false
  end
end

def pid_path(env)
  File.join env[:install_dir], SOLR_PID_FILE
end
