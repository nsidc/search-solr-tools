namespace :build do
  desc "Setup unconfigured solr instance"
  task :setup, :environment do |t, args|
    setup_solr args
  end
  desc "Build Artifact"
  task :artifact, :environment do |t, args|
    env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
    setup_solr(args)
    create_tarball(args, env)
  end
  desc "Clean deployment target"
  task :clean, :environment do |t, args|
    env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
    sh "#{env[:prefix]} rm -Rf #{env[:deployment_target]}/solr/*"
  end
  desc "Deploy artifact"
  task :deploy, :environment do |t, args|
    env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
    sh "cd #{env[:deployment_target]}; #{env[:prefix]} tar -xvf #{env[:repo_dir]}/nsidc_solr_search#{ENV['ARTIFACT_VERSION']}.tar; chmod u+x init"
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
end
