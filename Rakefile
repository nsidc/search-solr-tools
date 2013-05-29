require 'fileutils'

SOLR_ENVIRONMENTS = {
    :local => {
      :install_dir => '/opt/solr/dev',
      :collection_dir => 'solr/collection1/',
      :prefix => 'sudo'
    },
    :integration => {
      :install_dir => "./solr",
      :collection_dir => "solr/#{ENV["collection"]}",
      :prefix => ''
    }
}
SOLR_START_JAR = 'start.jar'
SOLR_PID_FILE = 'solr.pid'

task :setup, :environment do |t, args|
  setup_solr args
end

task :update_index, :environment do |t, args|
  copy_index_file args
end

task :start_solr, :environment do |t, args|
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  pid_file = pid_path env
  stop(pid_file, args)

  pid = fork do
    Process.setsid
    STDIN.reopen('/dev/null')
    STDOUT.reopen('/dev/null')
    STDERR.reopen(STDOUT)
    run env
  end
  sh "#{env[:prefix]} sh -c \"echo '#{pid}' > #{pid_file}\""
end

task :stop_solr, :environment do |t, args|
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  pid_file = pid_path env
  if !stop(pid_file, args)
    raise "No PID file at #{pid_file}"
  end
end

def setup_solr(args)
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  sh "#{env[:prefix]} mv ./solr-*/example #{env[:install_dir]}"
  sh "#{env[:prefix]} mv #{env[:install_dir]}/solr/collection1 #{env[:install_dir]}/#{env[:collection_dir]}"
  sh "#{env[:prefix]} cp schema.xml #{env[:install_dir]}/#{env[:collection_dir]}/conf/schema.xml"
  sh "#{env[:prefix]} cp solrconfig.xml #{env[:install_dir]}/#{env[:collection_dir]}/conf/solrconfig.xml"
  sh "#{env[:prefix]} cp nsidc_oai_iso.xslt #{env[:install_dir]}/#{env[:collection_dir]}/conf/xslt/nsidc_oai_iso.xslt"
  sh "#{env[:prefix]} cp solr.xml #{env[:install_dir]}/#{env[:collection_dir]}/solr.xml"
end

def copy_index_file(args)
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  sh "#{env[:prefix]} cp schema.xml #{env[:install_dir]}/#{env[:conf_dir]}"

end

def run(env)
  exec "cd #{env[:install_dir]}; #{env[:prefix]} java -jar #{SOLR_START_JAR}"
end

def stop(pid_file, args)
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  if File.exist?(pid_file)
    pid = IO.read(pid_file).to_i

    begin
      sh "#{env[:prefix]}  kill -15 -#{pid}"
      true
    rescue
      warn "Process with PID #{pid} is no longer running"
    ensure
      sh "#{env[:prefix]} rm #{pid_file}"
    end
  else
    false
  end
end

def pid_path(env)
  File.join env[:install_dir], SOLR_PID_FILE
end
