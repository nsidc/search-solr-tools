require 'fileutils'

SOLR_ENVIRONMENTS = {
    :local => {
      :install_dir => '/opt/solr/dev',
      :conf_dir => 'solr/collection1/conf'
    }
}

task :update_index, :environemnt do |t, args|
  copy_index_file args
end

task :start_solr, :environemnt do |t, args|
  copy_index_file args

  env = SOLR_ENVIRONMENTS[args[:environemnt].to_sym]
  sh "cd #{env[:install_dir]}; sudo java -jar start.jar"
end

def copy_index_file args
  env = SOLR_ENVIRONMENTS[args[:environemnt].to_sym]
  sh "sudo cp schema.xml #{env[:install_dir]}/#{env[:conf_dir]}"
end