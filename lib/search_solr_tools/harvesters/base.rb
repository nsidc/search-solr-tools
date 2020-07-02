require 'multi_json'
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'rsolr'
require 'time'

module SearchSolrTools
  module Harvesters
    # base class for solr harvesters
    class Base
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

      # Some data providers require encoding (such as URI.encode),
      # while others barf on encoding.  The default is to just
      # return url, override this in the subclass if special
      # encoding is needed.
      def encode_data_provider_url(url)
        url
      end

      def harvest_and_delete(harvest_method, delete_constraints, solr_core = SolrEnvironments[@environment][:collection_name])
        start_time = Time.now.utc.iso8601
        harvest_method.call
        delete_old_documents start_time, delete_constraints, solr_core
      end

      def delete_old_documents(timestamp, constraints, solr_core, force = false)
        constraints = sanitize_data_centers_constraints(constraints)
        delete_query = "last_update:[* TO #{timestamp}] AND #{constraints}"
        solr = RSolr.connect url: solr_url + "/#{solr_core}"
        unchanged_count = (solr.get 'select', params: { wt: :ruby, q: delete_query, rows: 0 })['response']['numFound'].to_i
        if unchanged_count == 0
          puts "All documents were updated after #{timestamp}, nothing to delete"
        else
          puts "Begin removing documents older than #{timestamp}"
          remove_documents(solr, delete_query, constraints, force, unchanged_count)
        end
      end

      def sanitize_data_centers_constraints(query_string)
        # Remove lucene special characters, preserve the query parameter and compress whitespace
        query_string.gsub!(/[:&|!~\-\(\)\{\}\[\]\^\*\?\+]+/, ' ')
        query_string.gsub!(/data_centers /, 'data_centers:')
        query_string.gsub!(/source /, 'source:')
        query_string.squeeze(' ').strip
      end

      def remove_documents(solr, delete_query, constraints, force, numfound)
        all_response_count = (solr.get 'select', params: { wt: :ruby, q: constraints, rows: 0 })['response']['numFound']
        if force || (numfound / all_response_count.to_f < DELETE_DOCUMENTS_RATIO)
          puts "Deleting #{numfound} documents for #{constraints}"
          solr.delete_by_query delete_query
          solr.commit
        else
          puts "Failed to delete records older than current harvest start because they exceeded #{DELETE_DOCUMENTS_RATIO} of the total records for this data center."
          puts "\tTotal records: #{all_response_count}"
          puts "\tNon-updated records: #{numfound}"
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
        return success if content_type == XML_CONTENT_TYPE && !doc_valid?(doc)

        doc_serialized = get_serialized_doc(doc, content_type)

        # Some docs will cause solr to time out during the POST
        begin
          RestClient.post(url, doc_serialized, content_type: content_type) do |response, _request, _result|
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

        request_url = encode_data_provider_url(request_url)

        begin
          puts "Request: #{request_url}"
          response = open(request_url, read_timeout: timeout, 'Content-Type' => content_type)
        rescue OpenURI::HTTPError, Timeout::Error, Errno::ETIMEDOUT => e
          retries_left -= 1
          puts "## REQUEST FAILED ## #{e.class} ## Retrying #{retries_left} more times..."

          retry if retries_left > 0

          raise e if @die_on_failure
          return
        end
        doc = Nokogiri.XML(response)
        doc.xpath(metadata_path, Helpers::IsoNamespaces.namespaces(doc))
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
      def doc_valid?(doc)
        spatial_coverages = doc.xpath(".//field[@name='spatial_coverages']").first
        return true if spatial_coverages.nil?

        spatial_coverages = spatial_coverages.text.split(' ')

        # We've only seen the failure with 4 spatial coverage values
        return true if spatial_coverages.size < 4

        valid_solr_spatial_coverage?(spatial_coverages)
      end

      # spatial_coverages is an array with length 4:
      # [North, East, South, West]
      def valid_solr_spatial_coverage?(spatial_coverages)
        north, east, south, west = spatial_coverages

        polar_point = (north == south) && (north.to_f.abs == 90)

        (east == west) || !polar_point
      end
    end
  end
end
