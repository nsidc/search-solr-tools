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

  # Update Solr with a set of documents
  def insert_solr_docs(docs)
    url = solr_url + '/update?commit=true'
    RestClient.post(url, (docs.respond_to?(:to_xml) ? docs.to_xml : docs), { content_type: 'text/xml; charset=utf-8' }) do |response, request, result|
      case response.code
      when 200
        response
      else
        puts "Harvest failed! Server response was:\n\n #{response.body}"
      end
    end
  end

  # Get results from some ISO end point specified in the query string
  def get_results(request_url, metadata_path)
    Nokogiri.XML(open(request_url, read_timeout: 1200)).xpath(metadata_path, ISO_NAMESPACES)
  end

  # returns Nokogiri XML document with content
  # '<?xml version="1.0"?><add/>'
  def create_new_solr_add_doc
    doc = Nokogiri::XML::Document.new
    doc.root = Nokogiri::XML::Node.new('add', doc)
    doc
  end
end