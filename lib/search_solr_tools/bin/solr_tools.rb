#!/usr/bin/env ruby
require 'search_solr_tools'
require 'thor'

class SolrHarvestCLI < Thor
  desc 'harvest', 'Harvest from one of the ADE harvesters'
  option :from, type: :array, required: true
  option :environment, required: true
  option :die_on_failure, type: :boolean

  def harvest(die_on_failure = options[:die_on_failure] || false)
    options[:from].each do|target|
      puts harvester_map["#{target}"]
      begin
        harvest_class = get_harvester_class(target)
        harvester = harvest_class.new options[:environment], die_on_failure
        harvester.harvest_and_delete
      rescue => e
        puts "harvest failed for #{target}: #{e.message}"
        raise e if die_on_failure
      end
    end
  end

  desc 'list_harvesters', 'List all harvesters'
  def list_harvesters
    harvester_map.each { |k, _v| puts k }
  end

  desc 'delete_all', 'Delete all documents from the index'
  option :environment, required: true
  def delete_all
    env = SolrEnvironments[options[:environment]]
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<delete><query>*:*</query></delete>'"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<commit/>'"
  end

  desc 'delete_all_auto_suggest', 'Delete all documents from the auto_suggest index'
  option :environment, required: true
  def delete_all_auto_suggest
    env = SolrEnvironments[options[:environment]]
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<delete><query>*:*</query></delete>'"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update' -H 'Content-Type: text/xml; charset=utf-8' --data '<commit/>'"
  end

  desc 'delete_by_data_center', 'Force deletion of documents for a specific data center with timestamps before the passed timestamp in format iso8601 (2014-07-14T21:49:21Z)'
  option :timestamp, required: true
  option :environment, required: true
  option :from,  required: true
  def delete_by_data_center
    harvester = get_harvester_class(options[:from]).new options[:environment]
    harvester.delete_old_documents(options[:timestamp],
                                   "data_centers:\"#{SolrFormat::DATA_CENTER_NAMES[options[:from].upcase.to_sym][:long_name]}\"",
                                   SolrEnvironments[harvester.environment][:collection_name],
                                   true
                                  )
  end

  no_tasks do
    def harvester_map
      {
        'cisl' => 'Cisl',
        'echo' => 'Echo',
        'eol' => 'Eol',
        'ices' => 'Ices',
        'nmi' => 'Nmi',
        'nodc' => 'Nodc',
        'rda' => 'Rda',
        'usgs' => 'Usgs',
        'tdar' => 'Tdar',
        'pdc' => 'Pdc',
        'nsidc' => 'NsidcJson',
        'auto_suggest' => 'AutoSuggest'
      }
    end

    def get_harvester_class(data_center_name)
      SearchSolrTools::Harvesters.const_get harvester_class_name(data_center_name)
    end

    def harvester_class_name(data_center_name)
      name = data_center_name.downcase
      harvester_map["#{name}"].to_s.empty? ? fail("Invalid data center #{name}") : harvester_map["#{name}"]
    end
  end
end
SolrHarvestCLI.start(ARGV)
