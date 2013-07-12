
def collection_dir(env)
  File.join env[:collection_path], env[:collection_name]
end

def pid_path(env)
  File.join build_run_dir(env), SolrEnvironments.PidFile
end

def generate_version_id
  "#{ENV['BUILD_NUMBER']}"
end

def build_run_dir(env)
  env[:run_dir].nil? ? "#{env[:deployment_target]}/#{env[:setup_dir]}" : "#{env[:run_dir]}"
end

def run(env)
  exec  "cd '#{build_run_dir(env)}'; #{env[:prefix]} java -jar #{SolrEnvironments.JarFile} -Djetty.port=#{env[:port]}"
end

def stop(pid_file, args, env)
  if File.exist?(pid_file)
    pid = IO.read(pid_file).to_i
    begin
      sh "#{env[:prefix]} kill -9 -#{pid}"
      true
    rescue
      warn "Process with PID #{pid} is no longer running"
    ensure
      sh "#{env[:prefix]} rm #{pid_file}"
    end
  end
end

def setup_solr(args)
  env = SolrEnvironments[args[:environment]]
  src_collection = "#{env[:setup_dir]}/solr/collection1"
  target_collection = "#{env[:setup_dir]}/#{collection_dir(env)}"
  unless src_collection.eql?(target_collection)
    sh "#{env[:prefix]} mv #{src_collection} #{target_collection}"
  end
  sh "#{env[:prefix]} cp schema.xml #{env[:setup_dir]}/#{collection_dir(env)}/conf/schema.xml"
  sh "#{env[:prefix]} cp solrconfig.xml #{env[:setup_dir]}/#{collection_dir(env)}/conf/solrconfig.xml"
  sh "#{env[:prefix]} cp nsidc_oai_iso.xslt #{env[:setup_dir]}/#{collection_dir(env)}/conf/xslt/nsidc_oai_iso.xslt"
  sh "#{env[:prefix]} cp ade_oai_iso.xslt #{env[:setup_dir]}/#{collection_dir(env)}/conf/xslt/ade_oai_iso.xslt"
  configure_collection(env[:collection_name], "#{env[:setup_dir]}/solr", "#{args[:environment]}")
end

def create_tarball(args, env)
  version_id = generate_version_id
  sh "tar -cvzf #{env[:repo_dir]}/nsidc_solr_search#{version_id}.tar solr solr-4.3.0/contrib solr-4.3.0/dist solr-4.3.0/example Rakefile Gemfile* lib tasks harvest_init init nsidc_oai_iso.xslt ade_oai_iso.xslt config"
end

def configure_collection(collection, target, environment )
  text = File.read('solr.xml')
  replace = text.gsub(/collection1/, collection)
  if(environment == "development")
    sh "sudo chgrp vagrant #{target}/solr.xml;sudo chmod 775 #{target}/solr.xml"
  end
  File.open("#{target}/solr.xml", "w") {|file| file.puts replace}
end

def server_status(pid_file, args, env)
  if File.exists?(pid_file)
    pid = IO.read(pid_file).to_i
    begin
      Process.kill(0, Integer(pid))
    rescue                      # changed uid
      warn "Process #{pid} has ceased, changed uid or another error has prevented evaluation"
      stop(pid_file, args, env)
      false
    end
    puts "Server is up running as pid #{pid}"
    true
  else
    warn "No pid file detected, server is not running"
    false
  end
end
