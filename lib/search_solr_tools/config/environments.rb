require 'yaml'

module SearchSolrTools
  # configuration to work with solr locally, or on integration/qa/staging/prod
  module SolrEnvironments
    YAML_ENVS = YAML.load_file(File.expand_path('../environments.yaml', __FILE__))

    def self.[](env = :development)
      YAML_ENVS[:common].merge(YAML_ENVS[env.to_sym])
    end
  end
end
