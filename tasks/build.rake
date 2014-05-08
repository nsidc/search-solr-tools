namespace :build do
  desc 'Setup unconfigured solr instance'
  task :setup, :environment do |t, args|
    setup_solr args
  end

  desc 'Build Artifact'
  task :artifact, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    setup_solr(args)
    create_tarball(args, env)
  end

  desc 'Build Artifact without Solr instance'
  task :artifact_no_solr do |t, args|
    create_tarball_no_solr(args)
  end

  desc 'Clean deployment target'
  task :clean, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    sh "#{env[:prefix]} rm -Rf #{env[:deployment_target]}/solr/*"
  end

  desc 'Deploy artifact'
  task :deploy, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    sh "cd #{env[:deployment_target]}; pwd; #{env[:prefix]} tar -xvf #{env[:repo_dir]}/nsidc_solr_search#{ENV['ARTIFACT_VERSION']}.tar; chmod u+x init"
    if args[:environment] != 'development'
      sh "chmod -R 775 #{env[:deployment_target]}/*"
      sh "chgrp -R webapp #{env[:deployment_target]}/*"
    end
  end

  desc 'Add build version to successfully deployed artifacts log'
  task :add_build_version_to_log, :environment, :build do |t, args|
    env = SolrEnvironments[args[:environment]]
    version_id = args[:build] || generate_version_id
    deployment_log = "#{env[:repo_dir]}/deployable_versions_" + [args[:environment]][0]
    unless File.exists?(deployment_log)
      File.open(deployment_log, 'w') do |f|
        f << 'buildVersion=\n'
        f << 'latestVersion='
      end
    end
    version_in_list = nil
    File.open(deployment_log, 'r') { |f| version_in_list = f.read =~ /[=,]#{version_id}\,/ }
    if !version_in_list
      puts "Adding version #{version_id} to #{deployment_log}"
      `sed -i "s/buildVersions=/buildVersions=#{version_id},/" #{deployment_log}`
      `sed -i "s/latestVersion=/latestVersion=#{version_id},/" #{deployment_log}`
    else
      puts "version #{version_id} is already in the deployment list."
    end
  end

  desc 'Display the latest artifact version from the specified log'
  task :latest_build_version, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    deployment_log = "#{env[:repo_dir]}/deployable_versions_" + [args[:environment]][0]
    version_id = `grep latestVersion= deployable_versions_vm | awk -F \= {'print $2'}`
    puts version_id
  end
end
