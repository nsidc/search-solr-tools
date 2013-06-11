
def pid_path(env)
  File.join env[:deployment_target], SOLR_PID_FILE
end

def generate_version_id
  "#{ENV['BUILD_NUMBER']}"
end

def run(env)
  exec "cd #{env[:deployment_target]}/#{env[:setup_dir]}; #{env[:prefix]} java -jar #{SOLR_START_JAR} -Djetty.port=#{env[:port]} > output.log 2>&1"
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
      sh "#{env[:prefix]} rm -f #{env[:deployment_target]}/#{env[:setup_dir]}/#{env[:collection_dir]}/data/index/write.lock"
    end
  else
    false
  end
end

def setup_solr(args)
  env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
  src_collection = "#{env[:setup_dir]}/solr/collection1"
  target_collection = "#{env[:setup_dir]}/#{env[:collection_dir]}"
  unless src_collection.eql?(target_collection)
    sh "#{env[:prefix]} mv #{src_collection} #{target_collection}"
  end
  sh "#{env[:prefix]} cp schema.xml #{env[:setup_dir]}/#{env[:collection_dir]}/conf/schema.xml"
  sh "#{env[:prefix]} cp solrconfig.xml #{env[:setup_dir]}/#{env[:collection_dir]}/conf/solrconfig.xml"
  sh "#{env[:prefix]} cp nsidc_oai_iso.xslt #{env[:setup_dir]}/#{env[:collection_dir]}/conf/xslt/nsidc_oai_iso.xslt"
  configure_collection("#{ENV['collection']}", "#{env[:setup_dir]}/solr", "#{args[:environment]}")
end

def create_tarball(args, env)
  version_id = generate_version_id
  sh "tar -cvzf #{env[:repo_dir]}/nsidc_solr_search#{version_id}.tar solr solr-4.3.0/contrib solr-4.3.0/dist solr-4.3.0/example Rakefile Gemfile* lib tasks init nsidc_oai_iso.xslt"
end

def configure_collection(collection, target, environment )
  text = File.read('solr.xml')
  replace = text.gsub(/collection1/, collection)
  if(environment == "development")
    sh "sudo chgrp vagrant #{target}/solr.xml;sudo chmod 775 #{target}/solr.xml"
  end
  File.open("#{target}/solr.xml", "w") {|file| file.puts replace}
end