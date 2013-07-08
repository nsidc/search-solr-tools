namespace :harvest do
require 'nokogiri'
  desc "Harvest NSIDC_OAI data"
  task :nsidc_oai_iso, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    sh "curl -s '#{env[:oai_url]}' | xsltproc ./nsidc_oai_iso.xslt - > oai_output.xml"
    sh "curl 'http://#{env[:host]}:#{env[:port]}/solr/update?commit=true' -H 'Content-Type: text/xml; charset=utf-8' --data-binary @oai_output.xml"
  end
  desc "Havest ALL data"
  task :ade, :environment do |t, args|
    env = SolrEnvironments[args[:environment]]
    startIndex = 1
    pageSize = 25
    resultCounts = getNumberOfRecords env[:gi_cat_csw_url]
    puts resultCounts.to_i
    while startIndex - 1 < resultCounts.to_i
      result_query_url = env[:gi_cat_csw_url] + "?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=results&outputFormat=application/xml&maxRecords=#{pageSize}&startPosition=#{startIndex}&outputSchema=http://www.isotc211.org/2005/gmd"
      sh "curl -s '#{result_query_url}' | xsltproc ./ade_eol_thredds.xslt - > ade_oai_output.xml"
      sh "curl -a 'http://#{env[:host]}:#{env[:port]}/solr/update?commit=true' -H 'Content-Type: text/xml; charset=utf-8' --data-binary @ade_oai_output.xml"
      startIndex += pageSize
    end
    
  end

  def getNumberOfRecords(url)
    count_url =  url + '?service=CSW&version=2.0.2&request=GetRecords&TypeNames=gmd:MD_Metadata&namespace=xmlns(gmd=http://www.isotc211.org/2005/gmd)&ElementSetName=full&resultType=hits&outputFormat=application/xml&maxRecords=1&startPosition=1&outputSchema=http://www.isotc211.org/2005/gmd'
    puts count_url
    sh "curl -s '#{count_url}' > count.xml"
    resultsCount = Nokogiri::XML(File.open("count.xml")).xpath("//csw:SearchResults").first['numberOfRecordsMatched']
    puts resultsCount
    return resultsCount
  end
end
