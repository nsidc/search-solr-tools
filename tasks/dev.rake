namespace :dev do
  desc 'Deploy configuration files'
  task :deploy_schema do
    sh 'sudo cp schema.xml /opt/solr/solr/nsidc_oai/conf/schema.xml'
  end

  task :deploy_config, :config_dir do |t, args|
    args.with_defaults(:config_dir => '~/puppet-solr')
    sh "sudo cp #{args[:config_dir]}/files/solr.xml /opt/solr/solr/solr.xml"
    sh "sudo cp #{args[:config_dir]}/files/solrconfig.xml /opt/solr/solr/nsidc_oai/conf/solrconfig.xml"
  end

  desc 'Start the server'
  task :start do
    sh 'sudo service solr start'
  end

  task :stop do
    sh 'sudo service solr stop'
  end

  desc 'Restart the server'
  task :restart do
    sh 'sudo service solr restart'
  end

  desc 'Run server:start, harvest:delete_all, harvest:nsidc_json in one task'
  task restart_with_clean_nsidc_harvest: ['dev:deploy_schema', 'dev:restart'] do
    puts 'Sleeping 10 seconds for server to start'
    sleep(10)
    Rake::Task['harvest:delete_all'].invoke
    Rake::Task['harvest:nsidc_json'].invoke
  end

  desc 'Deploys a new solr config and schema, restarts the server and then reharvests'
  task :restart_with_new_config, :config_dir do |t, args|
    Rake::Task['dev:deploy_config'].invoke(args[:config_dir])
    Rake::Task['dev:deploy_schema'].invoke
    Rake::Task['dev:restart'].invoke

    puts 'Sleeping 10 seconds for server to start'
    sleep(10)

    Rake::Task['harvest:delete_all'].invoke
    Rake::Task['harvest:nsidc_json'].invoke
  end
end
