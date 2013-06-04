require 'fileutils'

SOLR_ENVIRONMENTS = {
    :development => {
      :setup_dir => './solr/example',
      :deployment_target => "/opt/solr/dev/",
      :collection_dir => "solr/#{ENV['collection']}",
      :prefix => 'sudo',
      :port => '9283',
      :repo_dir => '/home/vagrant/workspace/nsidc-solr/repo/'
    },
    :integration => {
      :setup_dir => './solr/example',
      :deployment_target => '/disks/integration/live/apps/nsidc-open-search-solr/',
      :collection_dir => "solr/#{ENV['collection']}",
      :prefix => '',
      :port => '9283',
      :repo_dir => '/disks/integration/san/INTRANET/REPO/nsidc_search_solr/'
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
  sh "cd #{env[:deployment_target]}; #{env[:prefix]} tar -xvf #{env[:repo_dir]}/nsidc_solr_search#{ENV['ARTIFACT_VERSION']}.tar"
end

def generate_version_id()
  "#{ENV['BUILD_NUMBER']}"
end

def create_tarball(args, env)
  version_id = generate_version_id
  sh "tar -cvzf #{env[:repo_dir]}/nsidc_solr_search#{version_id}.tar solr-4.3.0 solr"
end
def setup_solr(args)
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  sh "#{env[:prefix]} mv #{env[:setup_dir]}/solr/collection1 #{env[:setup_dir]}/#{env[:collection_dir]}"
  sh "#{env[:prefix]} cp schema.xml #{env[:setup_dir]}/#{env[:collection_dir]}/conf/schema.xml"
  sh "#{env[:prefix]} cp solrconfig.xml #{env[:setup_dir]}/#{env[:collection_dir]}/conf/solrconfig.xml"
  sh "#{env[:prefix]} cp nsidc_oai_iso.xslt #{env[:setup_dir]}/#{env[:collection_dir]}/conf/xslt/nsidc_oai_iso.xslt"
  configure_collection("#{ENV['collection']}", "#{env[:setup_dir]}/solr")
end

def configure_collection(collection, target)
  text = File.read('solr.xml')
  replace = text.gsub(/collection1/, collection)
  File.open("#{target}/solr.xml", "w") {|file| file.puts replace}
end

def run(env)
  exec "cd #{env[:deployment_target]}/#{env[:setup_dir]}; #{env[:prefix]} java -jar #{SOLR_START_JAR}"
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
  File.join env[:deployment_target], SOLR_PID_FILE
end
