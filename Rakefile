require 'fileutils'

SOLR_ENVIRONMENTS = {
    :development => {
      :setup_dir => '/opt/solr/dev/',
      :deployment_target => '~/solr_deployment',
      :collection_dir => "solr/#{ENV['collection']}",
      :prefix => 'sudo',
      :port => '9283',
      :repo_dir => '~/solr_repo/',
      :oai_url => 'http://integration.nsidc.org/api/oai/provider?verb=ListRecords&metadataPrefix=iso'
    },
    :integration => {
      :setup_dir => './solr/example',
      :deployment_target => '/disks/integration/live/apps/nsidc-open-search-solr/',
      :collection_dir => "solr/#{ENV['collection']}",
      :prefix => '',
      :port => '9283',
      :repo_dir => '/disks/integration/san/INTRANET/REPO/nsidc_search_solr/',
      :oai_url => 'http://liquid.colorado.edu:11680/metadata-interface/oai/provider?verb=ListRecords&metadataPrefix=iso'
    },
    :qa => {
      :setup_dir => './solr/example',
      :deployment_target => '/disks/qa/live/apps/nsidc-open-search-solr/',
      :collection_dir => "solr/#{ENV['collection']}",
      :prefix => '',
      :port => '9283',
      :repo_dir => '/disks/integration/san/INTRANET/REPO/nsidc_search_solr/',
      :oai_url => 'http://liquid.colorado.edu:11680/metadata-interface/oai/provider?verb=ListRecords&metadataPrefix=iso'
    }
}
SOLR_START_JAR = 'start.jar'
SOLR_PID_FILE = 'solr.pid'
require './lib/build_subs.rb'
Dir.glob('./tasks/*.rake').each { |r| import r }

