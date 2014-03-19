require 'rest-client'
require 'nokogiri'
require 'open-uri'
require 'multi_json'
require './lib/selectors/helpers/iso_namespaces'

# base class for solr harvesters
class HarvesterBase
  attr_accessor :environment

  XML_CONTENT_TYPE = 'text/xml; charset=utf-8'
  JSON_CONTENT_TYPE = 'application/json; charset=utf-8'

  def initialize(env = 'development')
    @environment = env
  end

  def solr_url
    env = SolrEnvironments[@environment]
    "http://#{env[:host]}:#{env[:port]}/#{env[:collection_path]}"
  end

  # Update Solr with an array of Nokogiri xml documents, report number of successfully added documents
  def insert_solr_docs(docs, content_type = XML_CONTENT_TYPE)
    success = 0
    failure = 0
    docs.each do |doc|
      insert_solr_doc(doc, content_type) ? success += 1 : failure += 1
    end
    puts "#{success} document#{success == 1 ? '' : 's'} successfully added to Solr."
    puts "#{failure} document#{failure == 1 ? '' : 's'} not added to Solr."
  end

  def insert_solr_doc(doc, content_type = XML_CONTENT_TYPE)
    url = solr_url + '/update?commit=true'
    success = false
    doc_serialized = get_serialized_doc(doc, content_type)
    RestClient.post(url, doc_serialized,  content_type: content_type) do |response, request, result|
      response.code == 200 ? success = true : puts(response.body)
    end
    success
  end

  def get_serialized_doc(doc, content_type)
    if content_type.eql?(XML_CONTENT_TYPE)
      return doc.respond_to?(:to_xml) ? doc.to_xml : doc
    elsif content_type.eql?(JSON_CONTENT_TYPE)
      return MultiJson.dump(doc)
    else
      return doc
    end
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
