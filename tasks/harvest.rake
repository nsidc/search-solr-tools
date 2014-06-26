require './lib/nsidc_json_harvester.rb'
require './lib/auto_suggest_harvester.rb'

namespace :harvest do

  desc 'Harvest all of NSIDC and ADE data'
  task :all, :environment do |t, args|
    Rake::Task['harvest:nsidc_json'].invoke(args[:environment])
    Rake::Task['harvest:all_ade'].invoke(args[:environment])
  end

  desc 'Harvest NSIDC JSON data'
  task :nsidc_json, :environment do |t, args|
    begin
      harvester = NsidcJsonHarvester.new args[:environment]
      harvester.harvest_nsidc_json_into_solr
    rescue
      puts 'Harvest failed for NSIDC'
      next
    end
  end

  desc 'Harvest auto suggest'
  task :auto_suggest, :environment do |t, args|
    harvester = AutoSuggestHarvester.new args[:environment]
    harvester.harvest_nsidc
  end

  desc 'Delete all documents from the index'
  task :delete_all, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<delete><query>*:*</query></delete>'"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<commit/>'"
  end

  desc 'Delete all documents from the auto suggest index'
  task :delete_all_auto_suggest, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/auto_suggest/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<delete><query>*:*</query></delete>'"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/auto_suggest/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<commit/>'"
  end
end
