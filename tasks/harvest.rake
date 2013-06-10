namespace :harvest do
  desc "Harvest NSIDC_OAI data"
  task :nsidc_oai_iso, :environment do |t, args|
    env = SOLR_ENVIRONMENTS[args[:environment].to_sym]
    sh "curl -s '#{env[:oai_url]}' | xsltproc ./nsidc_oai_iso.xslt - > oai_output.xml"
    sh "curl 'http://localhost:#{env[:port]}/solr/update?commit=true' -H 'Content-Type: text/xml; charset=utf-8' --data-binary @oai_output.xml"
  end
end