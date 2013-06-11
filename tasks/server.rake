namespace :server do
  desc "Start a configured solr instance"
  task :start, :environment do |t, args|
    env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
    pid_file = pid_path env
    stop(pid_file, args, env)

    pid = fork do
      Process.setsid
      STDIN.reopen('/dev/null')
      STDOUT.reopen('/dev/null')
      STDERR.reopen(STDOUT)
      run env
    end
    sh "#{env[:prefix]} sh -c \"echo '#{pid}' > #{pid_file}\""
    exit
  end

  desc "Stop the currently running solr instance"
  task :stop, :environment do |t, args|
    env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
    pid_file = pid_path env
    if !stop(pid_file, args, env)
      warn "No PID file at #{pid_file}"
    end
  end

  def server_status(pid_file)
    pid = IO.read(pid_file).to_i
    begin
      Process.kill(0, pid)
      true
    rescue Errno::EPERM
      puts "No permission to query #{pid}!";
      false
    rescue Errno::ESRCH
      puts "#{pid} is NOT running.";
      false
    rescue
      puts "Unable to determine status for #{pid} : #{$!}"
      false
    end
  end
end
