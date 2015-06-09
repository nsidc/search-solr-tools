require_relative './nsidc_json'

module SearchSolrTools
  module Harvesters
    # Harvests data from NSIDC OAI and inserts it into Solr after it has been translated
    class DevelopmentNsidcJson < NsidcJson
      def initialize(env = 'development', die_on_failure = false)
        super env, die_on_failure
      end

      def result_ids_from_nsidc
        ids = %w(ARCSS302 NSIDC-0051 NSIDC-0243 ARCSS303)

        response = '<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
      <responseDate>2014-06-11T18:28:20Z</responseDate>
      <request metadata_prefix="iso" verb="ListIdentifiers">http://integration.nsidc.org/oai</request>
      <ListIdentifiers>'

        ids.each do |id|
          response += "<header>
      <identifier>oai:nsidc/#{id}</identifier>
      <datestamp>2005-02-01T07:00:00Z</datestamp>
      </header>"
        end

        response += '</OAI-PMH>'

        doc = Nokogiri.XML(response)
        doc.xpath('//xmlns:identifier', IsoNamespaces.namespaces(doc))
      end
    end
  end
end