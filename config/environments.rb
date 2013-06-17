
module SolrEnvironments
  def self.[] (key)
    key_sym = (key || 'development').to_sym
    SOLR_ENVIRONMENTS[key_sym]
  end

  def self.JarFile
    'start.jar'
  end

  def self.PidFile
    'solr.pid'
  end

  private

  COMMON = {
      :setup_dir => './solr/example',
      :collection_name => 'nsidc_oai',
      :collection_path => 'solr',
      :prefix => '',
      :repo_dir => '/disks/integration/san/INTRANET/REPO/nsidc_search_solr/',
      :port => '9283'
  }

  SOLR_ENVIRONMENTS = {
      :development => {
          :setup_dir => '/opt/solr/dev',
          :deployment_target => '~/solr_deploy/',
          :run_dir => '/opt/solr/dev',
          :collection_name => 'collection1',
          :collection_path => 'solr',
          :prefix => 'sudo',
          :port => '8983',
          :repo_dir => '~/solr_repo/',
          :oai_url => 'http://integration.nsidc.org/api/oai/provider?verb=ListRecords&metadataPrefix=iso',
          :host => 'localhost'
      },
      :integration => COMMON.clone.merge({
                                             :deployment_target => '/disks/integration/live/apps/nsidc-open-search-solr/',
                                             :oai_url => 'http://liquid.colorado.edu:11680/metadata-interface/oai/provider?verb=ListRecords&metadataPrefix=iso',
                                             :host => 'liquid.colorado.edu'
                                         }),
      :qa => COMMON.clone.merge({
                                    :deployment_target => '/disks/qa/live/apps/nsidc-open-search-solr/',
                                    :oai_url => 'http://brash.colorado.edu:11680/metadata-interface/oai/provider?verb=ListRecords&metadataPrefix=iso',
                                    :host => 'brash.colorado.edu'
                                }),
      :staging => COMMON.clone.merge({
                                         :deployment_target => '/disks/staging/live/apps/nsidc-open-search-solr/',
                                         :oai_url => 'http://freeze.colorado.edu:11680/metadata-interface/oai/provider?verb=ListRecords&metadataPrefix=iso',
                                         :host => 'freeze.colorado.edu'
                                     })
  }
end
