require 'rest-client'
require 'nokogiri'
require 'open-uri'

# base class for solr harvesters
class HarvesterBase
  attr_accessor :environment

  def initialize(env = 'development')
    @environment = env
  end

  def solr_url
    env = SolrEnvironments[@environment]
    "http://#{env[:host]}:#{env[:port]}/#{env[:collection_path]}"
  end

  # Update Solr with an array of Nokogiri xml documents, report number of successfully added documents
  def insert_solr_docs(docs)
    success = 0
    failure = 0
    docs.each do |doc|
      insert_solr_doc(doc) ? success += 1 : failure += 1
    end
    puts "#{success} document#{success == 1 ? '' : 's'} successfully added to Solr."
    puts "#{failure} document#{failure == 1 ? '' : 's'} not added to Solr."
  end

  def insert_solr_doc(doc)
    url = solr_url + '/update?commit=true'
    success = false
    RestClient.post(url, (doc.respond_to?(:to_xml) ? doc.to_xml : doc), { content_type: 'text/xml; charset=utf-8' }) do |response, request, result|
      response.code == 200 ? success = true : puts(response.body)
    end
    success
  end

  # Get results from some ISO end point specified in the query string
  def get_results(request_url, metadata_path, content_type = 'application/xml')
    doc = Nokogiri.XML(open(request_url, read_timeout: 1200, 'Content-Type' => content_type))
    doc.xpath(metadata_path, IsoNamespaces.namespaces(doc))
  end

  # returns Nokogiri XML document with content
  # '<?xml version="1.0"?><add/>'
  def create_new_solr_add_doc
    doc = Nokogiri::XML::Document.new
    doc.root = Nokogiri::XML::Node.new('add', doc)
    doc
  end

  # returns a Nokogiri XML document with content
  # '<?xml version="1.0"?><add> <child /> </add>'
  def create_new_solr_add_doc_with_child(child)
    doc = create_new_solr_add_doc
    doc.root.add_child(child)
    doc
  end
end
