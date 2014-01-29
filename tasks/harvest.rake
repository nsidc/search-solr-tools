require './lib/ade_harvester.rb'
require './lib/nsidc_harvester.rb'
require './lib/nodc_harvester.rb'

namespace :harvest do

  desc 'Harvest NSIDC_OAI data'
  task :nsidc_oai_iso, :environment do |t, args|
    harvester = NsidcHarvester.new args[:environment]

    harvester.harvest_nsidc_oai_into_solr
  end

  desc 'Harvest NODC data'
  task :nodc, :environment do |t, args|
    harvester = NodcHarvester.new args[:environment]

    harvester.harvest_nodc_into_solr
  end

  desc 'Harvest ADE data'
  task :ade, :environment, :profile do |t, args|
    harvester = ADEHarvester.new(args[:environment], args[:profile])
    harvester.harvest_gi_cat_into_solr
  end

  desc 'Delete all documents from the index'
  task :delete_all, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<delete><query>*:*</query></delete>'"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<commit/>'"
  end
end
