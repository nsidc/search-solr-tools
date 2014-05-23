namespace :dev do
  desc 'Deploy configuration files'
  task :deploy_schema do
    sh 'sudo cp schema.xml /opt/solr/solr/nsidc_oai/conf/schema.xml'
  end

  desc 'Start the server'
  task :start do
    sh 'sudo service solr start'
  end

  desc 'Stop the server'
  task :stop do
    sh 'sudo service solr stop'
  end

  desc 'Restart the server'
  task :restart do
    sh 'sudo service solr restart'
  end

  desc 'Run server:stop, rake build:setup, server:start, harvest:delete_all, harvest:nsidc_oai_iso in one task'
  task restart_with_clean_nsidc_harvest: ['dev:deploy_schema', 'dev:restart'] do
    puts 'Sleeping 10 seconds for server to start'
    sleep(10)
    Rake::Task['harvest:delete_all'].invoke
    Rake::Task['harvest:nsidc_json'].invoke
  end
end