require 'time'
require 'rest-client'
require 'nokogiri'
require 'open-uri'
require 'multi_json'
require './lib/selectors/helpers/iso_namespaces'
require 'rsolr'

# base class for solr harvesters
class HarvesterBase
  attr_accessor :environment

  DELETE_DOCUMENTS_RATIO = 0.1
  XML_CONTENT_TYPE = 'text/xml; charset=utf-8'
  JSON_CONTENT_TYPE = 'application/json; charset=utf-8'

  def initialize(env = 'development', die_on_failure = false)
    @environment = env
    @die_on_failure = die_on_failure
  end

  def solr_url
    env = SolrEnvironments[@environment]
    "http://#{env[:host]}:#{env[:port]}/#{env[:collection_path]}"
  end

  def harvest_and_delete(harvest_method, delete_constraints, solr_core = SolrEnvironments[@environment][:collection_name])
    start_time = Time.now.utc.iso8601
    harvest_method.call
    delete_old_documents start_time, delete_constraints, solr_core
  end

  def delete_old_documents(before_timestamp, constraints, solr_core, force = false)
    delete_query = "last_update:[* TO #{before_timestamp}] AND #{constraints}"

    solr = RSolr.connect url: solr_url + "/#{solr_core}"
    all_response = solr.get 'select', params: { q: constraints, rows: 0 }
    not_updated_response = solr.get 'select', params: { q: delete_query, rows: 0 }

    if not_updated_response['response']['numFound'].to_i == 0
      puts "All documents were updated after #{before_timestamp}, nothing to delete"
    elsif force || not_updated_response['response']['numFound'].to_f / all_response['response']['numFound'].to_f < DELETE_DOCUMENTS_RATIO
      puts "Deleting #{not_updated_response['response']['numFound']} documents for #{constraints}"
      solr.delete_by_query delete_query
      solr.commit
    else
      puts "Failed to delete records older then #{before_timestamp} because they exceeded #{DELETE_DOCUMENTS_RATIO} of the total records for this data center."
      puts "\tTotal records: #{all_response['response']['numFound']}"
      puts "\tNon-updated records: #{not_updated_response['response']['numFound']}"
    end
  end

  # Update Solr with an array of Nokogiri xml documents, report number of successfully added documents
  def insert_solr_docs(docs, content_type = XML_CONTENT_TYPE, core = SolrEnvironments[@environment][:collection_name])
    success = 0
    failure = 0
    docs.each do |doc|
      insert_solr_doc(doc, content_type, core) ? success += 1 : failure += 1
    end
    puts "#{success} document#{success == 1 ? '' : 's'} successfully added to Solr."
    puts "#{failure} document#{failure == 1 ? '' : 's'} not added to Solr."
    fail 'Some documents failed to be inserted into Solr' if failure > 0
  end

  def insert_solr_doc(doc, content_type = XML_CONTENT_TYPE, core = SolrEnvironments[@environment][:collection_name])
    url = solr_url + "/#{core}/update?commit=true"
    success = false

    # Some of the docs will cause Solr to crash - CPU goes to 195% with `top` and it
    # doesn't seem to recover.
    return success unless doc_valid?(doc) if content_type == XML_CONTENT_TYPE

    doc_serialized = get_serialized_doc(doc, content_type)

    # Some docs will cause solr to time out during the POST
    begin
      RestClient.post(url, doc_serialized,  content_type: content_type) do |response, request, result|
        success = response.code == 200
        puts "Error for #{doc_serialized}\n\n response: #{response.body}" unless success
      end
    rescue => e
      puts "Rest exception while POSTing to Solr: #{e}, for doc: #{doc_serialized}"
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
    timeout = 300
    retries_left = 3

    begin
      puts "\nRequest: #{request_url}"
      response = open(URI.encode(request_url), read_timeout: timeout, 'Content-Type' => content_type)
    rescue OpenURI::HTTPError, Timeout::Error => e
      retries_left -= 1
      puts "\n## REQUEST FAILED ## Retrying #{retries_left} more times..."

      if retries_left > 0
        sleep 5
        retry
      else
        raise e if @die_on_failure
        return
      end
    end
    doc = Nokogiri.XML(response)
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

  # Make sure that Solr is able to accept this doc in a POST
  # input is a Nokogiri::XML::NodeSet object (maybe)
  def doc_valid?(doc)
    spatial_coverages = doc.xpath(".//field[@name='spatial_coverages']").first
    return true if spatial_coverages.nil?

    spatial_coverages = spatial_coverages.text.split(' ')

    # We've only seen the failure with 4 spatial coverage values
    return true if spatial_coverages.size < 4

    !spatial_coverage_invalid?(spatial_coverages)
  end

  # spatial_coverages is an array with length 4:
  # [North, East, South, West]

  # The failure occurs when the input is an infinitely narrow
  # line, as in the following xml:
  # <field name="spatial_coverages">-90 -180 -90 180</field>
  #
  # If N, S are the same and E, W span the globe, invalid
  def spatial_coverage_invalid?(spatial_coverages)
    (
      spatial_coverages.first.to_f.abs == 90 &&
      spatial_coverages.first == spatial_coverages[2] &&
      spatial_coverages[1].to_f.abs == 180 &&
      spatial_coverages.last.to_f.abs == 180
    ) || (
      spatial_coverages[1].to_f.abs == 180 &&
      spatial_coverages[1] == spatial_coverages.last &&
      spatial_coverages.first.to_f.abs == 90 &&
      spatial_coverages[2].to_f.abs == 90
    )
  end
end
