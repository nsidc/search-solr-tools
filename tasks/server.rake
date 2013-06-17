namespace :server do
  desc "Start a configured solr instance"
  task :start, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
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
    env = SolrEnvironments[args[:environment]]
    pid_file = pid_path env
    if !stop(pid_file, args, env)
      warn "No PID file at #{pid_file}"
    end
  end
  task :status, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    pid_file = pid_path env
    server_status(pid_file, args, env)
  end
end
