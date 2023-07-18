# frozen_string_literal: true

require 'multi_json'
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'rsolr'
require 'time'

require 'search_solr_tools'
require_relative '../helpers/iso_namespaces'
require_relative '../helpers/solr_format'

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

      # Ping the Solr instance to ensure that it's running.
      # The ping query is specified to manually check the title, as it's possible
      # there is no "default" query in the solr instance.
      def ping_solr(core = SolrEnvironments[@environment][:collection_name])
        url = solr_url + "/#{core}/admin/ping?df=title"
        success = false

        # Some docs will cause solr to time out during the POST
        begin
          RestClient.get(url) do |response, _request, _result|
            success = response.code == 200
            puts "Error in ping request: #{response.body}" unless success
          end
        rescue StandardError => e
          puts "Rest exception while pinging Solr: #{e}"
        end
        success
      end

      # This should be overridden by child classes to implement the ability
      # to "ping" the data center.  Returns true if the ping is successful (or, as
      # in this default, no ping method was defined)
      def ping_source
        puts 'Harvester does not have ping method defined, assuming true'
        true
      end

      def harvest_and_delete(harvest_method, delete_constraints, solr_core = SolrEnvironments[@environment][:collection_name])
        start_time = Time.now.utc.iso8601

        harvest_status = harvest_method.call
        delete_old_documents start_time, delete_constraints, solr_core

        harvest_status
      end

      def delete_old_documents(timestamp, constraints, solr_core, force = false)
        constraints = sanitize_data_centers_constraints(constraints)
        delete_query = "last_update:[* TO #{timestamp}] AND #{constraints}"
        solr = RSolr.connect url: solr_url + "/#{solr_core}"
        unchanged_count = (solr.get 'select', params: { wt: :ruby, q: delete_query, rows: 0 })['response']['numFound'].to_i
        if unchanged_count.zero?
          puts "All documents were updated after #{timestamp}, nothing to delete"
        else
          puts "Begin removing documents older than #{timestamp}"
          remove_documents(solr, delete_query, constraints, force, unchanged_count)
        end
      end

      def sanitize_data_centers_constraints(query_string)
        # Remove lucene special characters, preserve the query parameter and compress whitespace
        query_string.gsub!(/[:&|!~\-\(\)\{\}\[\]\^\*\?\+]+/, ' ')
        query_string.gsub!('data_centers ', 'data_centers:')
        query_string.gsub!('source ', 'source:')
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

        status = Helpers::HarvestStatus.new

        docs.each do |doc|
          doc_status = insert_solr_doc(doc, content_type, core)
          status.record_status doc_status
          doc_status == Helpers::HarvestStatus::INGEST_OK ? success += 1 : failure += 1
        end
        puts "#{success} document#{success == 1 ? '' : 's'} successfully added to Solr."
        puts "#{failure} document#{failure == 1 ? '' : 's'} not added to Solr."

        status
      end

      # TODO: Need to return a specific type of failure:
      #   - Bad record content identified and no ingest attempted
      #   - Solr tries to ingest document and fails (bad content not detected prior to ingest)
      #   - Solr cannot insert document for reasons other than the document structure and content.
      def insert_solr_doc(doc, content_type = XML_CONTENT_TYPE, core = SolrEnvironments[@environment][:collection_name])
        url = solr_url + "/#{core}/update?commit=true"
        status = Helpers::HarvestStatus::INGEST_OK

        # Some of the docs will cause Solr to crash - CPU goes to 195% with `top` and it
        # doesn't seem to recover.
        return Helpers::HarvestStatus::INGEST_ERR_INVALID_DOC if content_type == XML_CONTENT_TYPE && !doc_valid?(doc)

        doc_serialized = get_serialized_doc(doc, content_type)

        # Some docs will cause solr to time out during the POST
        begin
          RestClient.post(url, doc_serialized, content_type:) do |response, _request, _result|
            success = response.code == 200
            unless success
              puts "Error for #{doc_serialized}\n\n response: #{response.body}"
              status = Helpers::HarvestStatus::INGEST_ERR_SOLR_ERROR
            end
          end
        rescue StandardError => e
          # TODO: Need to provide more detail re: this failure so we know whether to
          #  exit the job with a status != 0
          puts "Rest exception while POSTing to Solr: #{e}, for doc: #{doc_serialized}"
          status = Helpers::HarvestStatus::INGEST_ERR_SOLR_ERROR
        end
        status
      end

      def get_serialized_doc(doc, content_type)
        if content_type.eql?(XML_CONTENT_TYPE)
          doc.respond_to?(:to_xml) ? doc.to_xml : doc
        elsif content_type.eql?(JSON_CONTENT_TYPE)
          MultiJson.dump(doc)
        else
          doc
        end
      end

      # Get results from an end point specified in the request_url
      def get_results(request_url, metadata_path, content_type = 'application/xml')
        timeout = 300
        retries_left = 3

        request_url = encode_data_provider_url(request_url)

        begin
          puts "Request: #{request_url}"
          response = URI.open(request_url, read_timeout: timeout, 'Content-Type' => content_type)
        rescue OpenURI::HTTPError, Timeout::Error, Errno::ETIMEDOUT => e
          retries_left -= 1
          puts "## REQUEST FAILED ## #{e.class} ## Retrying #{retries_left} more times..."

          retry if retries_left.positive?

          # TODO: - Do we really need this "die_on_failure" anymore?  The empty return
          #  will cause the "No Documents" error to be thrown in the harvester class
          #  now, so it will pretty much always "die on failure"
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

        spatial_coverages = spatial_coverages.text.split

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
