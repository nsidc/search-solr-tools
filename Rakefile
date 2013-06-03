require 'fileutils'

SOLR_ENVIRONMENTS = {
    :development => {
      :install_dir => '/opt/solr/dev',
      :collection_dir => 'solr/local_collection',
      :prefix => 'sudo',
      :port => '8983',
      :repo_dir => './',
      :deploy_dir => './deploy'
    },
    :integration => {
      :install_dir => "./solr",
      :collection_dir => "solr/#{ENV["collection"]}",
      :prefix => '',
      :port => '8983',
      :repo_dir => '/disks/integration/san/INTRANET/REPO/nsidc_search_solr/',
      :deploy_dir => './'
    }
}
SOLR_START_JAR = 'start.jar'
SOLR_PID_FILE = 'solr.pid'


desc "Setup unconfigured solr instance"
task :setup, :environment do |t, args|
  setup_solr args
end

desc "Start a configured solr instance"
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
  sh "echo cd #{env[:install_dir]}; #{env[:prefix]} java -jar #{SOLR_START_JAR} -D jetty.port=#{env[:port]}
  sh "#{env[:prefix]} sh -c \"echo '#{pid}' > #{pid_file}\""
end

desc "Stop the currently running solr instance"
task :stop_solr, :environment do |t, args|
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  pid_file = pid_path env
  if !stop(pid_file, args)
    warn "No PID file at #{pid_file}"
  end
end

desc "Add build version to successfully deployed artifacts log"
task :add_build_version_to_log, :environment do |t, args|
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  version_id = generate_version_id
  deployment_log = "#{env[:repo_dir]}/deployable_version_" + [args[:environment]][0]

  if(!File.exists?(deployment_log))
    File.open(deployment_log, 'w') { |f| f.write('buildVersion=') }
  end
  if(File.open(deployment_log, 'r') { |f| !f.read.include?(version_id) })
    `sed -i "s/buildVersion=/buildVersion=#{version_id},/" #{deployment_log}`
  end
end

desc "Build artifact"
task :build_artifact, :environment do |t, args|
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  setup_solr(args)
  create_tarball(args, env)
end

desc "Deploy artifact"
task :deploy_artifact, :environment do |t, args|
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  sh "#{env[:prefix]} tar -xvf #{env[:repo_dir]}/nsidc_solr_search#{ENV['ARTIFACT_VERSION']}.tar"
end

def generate_version_id()
  "#{ENV['BUILD_NUMBER']}"
end

def create_tarball(args, env)
  version_id = generate_version_id
  sh "tar -cvzf #{env[:repo_dir]}/nsidc_solr_search#{version_id}.tar solr"
end

def setup_solr(args)
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  sh "#{env[:prefix]} mv ./solr-*/example #{env[:install_dir]}"
  sh "#{env[:prefix]} mv #{env[:install_dir]}/solr/collection1 #{env[:install_dir]}/#{env[:collection_dir]}"
  sh "#{env[:prefix]} cp schema.xml #{env[:install_dir]}/#{env[:collection_dir]}/conf/schema.xml"
  sh "#{env[:prefix]} cp solrconfig.xml #{env[:install_dir]}/#{env[:collection_dir]}/conf/solrconfig.xml"
  sh "#{env[:prefix]} cp nsidc_oai_iso.xslt #{env[:install_dir]}/#{env[:collection_dir]}/conf/xslt/nsidc_oai_iso.xslt"
  sh "#{env[:prefix]} cp solr.xml #{env[:install_dir]}/#{env[:collection_dir]}/solr.xml"
  sh "#{env[:prefix]} rm -rf solr-*"
end

def run(env)
  exec "cd #{env[:install_dir]}; #{env[:prefix]} java -jar #{SOLR_START_JAR} -D jetty.port=#{env[:port]}"
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
