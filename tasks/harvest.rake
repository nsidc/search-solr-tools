require './lib/nsidc_json_harvester.rb'
require './lib/auto_suggest_harvester.rb'

namespace :harvest do
  desc 'Harvest all of NSIDC and ADE data and auto suggest'
  task :all, :environment, :die_on_failure do |_t, args|
    Rake::Task['harvest:nsidc_json'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:all_ade'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:nsidc_auto_suggest'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:ade_auto_suggest'].invoke(args[:environment], args[:die_on_failure])
  end

  desc 'Harvest NSIDC JSON data'
  task :nsidc_json, :environment, :die_on_failure do |_t, args|
    begin
      harvester = NsidcJsonHarvester.new args[:environment], args[:die_on_failure]
      harvester.harvest_and_delete
    rescue => e
      puts 'Harvest failed for NSIDC:' + e.message
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest auto suggest for nsidc'
  task :nsidc_auto_suggest, :environment, :die_on_failure do |_t, args|
    harvester = AutoSuggestHarvester.new args[:environment], args[:die_on_failure]
    harvester.harvest_and_delete_nsidc
  end

  desc 'Force deletion of documents for a specific data center with timestamps before the passed timestamp in format iso8601 (2014-07-14T21:49:21Z)
  Example: `rake harvest:delete_by_data_center[\'NSIDC\',\'2014-07-14T21:49:21Z\']`'
  task :delete_by_data_center, :data_center, :timestamp, :environment do |_t, args|
    harvester = HarvesterBase.new args[:environment]
    harvester.delete_old_documents args[:timestamp], "data_centers:\"#{SolrFormat::DATA_CENTER_NAMES[args[:data_center].to_sym][:long_name]}\"", SolrEnvironments[harvester.environment][:collection_name], true
  end

  desc 'List all the data centers'
  task :list_data_centers do
    SolrFormat::DATA_CENTER_NAMES.each do |code, names|
      puts "code: #{code}, short_name: #{names[:short_name]}, long_name: #{names[:long_name]}"
    end
  end

  desc 'Delete all documents from the index'
  task :delete_all, :environment do |_t, args|
    env = SolrEnvironments[args[:environment]]
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<delete><query>*:*</query></delete>'"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<commit/>'"
  end

  desc 'Delete all documents from the auto suggest index'
  task :delete_all_auto_suggest, :environment do |_t, args|
    env = SolrEnvironments[args[:environment]]
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/auto_suggest/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<delete><query>*:*</query></delete>'"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/auto_suggest/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<commit/>'"
  end
end
