require './lib/ade_harvester.rb'

namespace :harvest do

  desc 'Harvest NSIDC_OAI data'
  task :nsidc_oai_iso, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    sh "curl -s '#{env[:oai_url]}' | xsltproc ./nsidc_oai_iso.xslt - > oai_output.xml"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update?commit=true' -H 'Content-Type: text/xml; charset=utf-8' --data-binary @oai_output.xml"
  end

  desc 'Harvest ADE data'
  task :ade, :environment do |t, args|
    harvester = ADEHarvester.new args[:environment]

    harvester.harvest
  end

  desc 'Delete all documents from the index'
  task :delete_all, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<delete><query>*:*</query></delete>'"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<commit/>'"
  end
end
