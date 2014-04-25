require './lib/nsidc_harvester.rb'
require './lib/nsidc_json_harvester.rb'

namespace :harvest do

  desc 'Harvest all of NSIDC and ADE data'
  task :all, :environment do |t, args|
    Rake::Task['harvest:nsidc_json']
    Rake::Task['harvest:all_ade']
  end

  desc 'Run server:stop, rake build:setup, server:start, harvest:delete_all, harvest:nsidc_oai_iso in one task'
  task restart_with_clean_nsidc_harvest: ['server:stop', 'build:setup', 'server:start'] do
    puts 'Sleeping 10 seconds for server to start'
    sleep(10)
    Rake::Task['harvest:delete_all'].invoke
    Rake::Task['harvest:nsidc_json'].invoke
  end

  desc 'Harvest NSIDC_OAI data'
  task :nsidc_oai_iso, :environment do |t, args|
    harvester = NsidcHarvester.new args[:environment]

    harvester.harvest_nsidc_oai_into_solr
  end

  desc 'Harvest NSIDC JSON data'
  task :nsidc_json, :environment do |t, args|
    harvester = NsidcJsonHarvester.new args[:environment]

    harvester.harvest_nsidc_json_into_solr
  end

  desc 'Delete all documents from the index'
  task :delete_all, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<delete><query>*:*</query></delete>'"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<commit/>'"
  end
end
