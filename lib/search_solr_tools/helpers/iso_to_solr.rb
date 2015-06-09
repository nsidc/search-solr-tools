require 'nokogiri'

require 'search_solr_tools/helpers/selectors'

module SearchSolrTools
  module Helpers
    # Translates ISO nokogiri documents into solr nokogiri documents using a hash driver object
    # This class should be constructed passing the selector file hash as a parameter (see selectors.rb)
    # after creating an instance we call transtale with a nokogiri iso document as a parameter.
    class IsoToSolr
      def initialize(selector)
        @fields = SELECTORS[selector]
        @multiple_whitespace = /\s{2,}/ # save the regex so it is not recompiled every time format_field() is called
      end

      # this will return a nodeset with all the elements that matched the xpath
      def eval_xpath(iso_xml_doc, xpath, multivalue, reduce)
        fields = []
        begin
          iso_xml_doc.xpath(xpath, IsoNamespaces.namespaces(iso_xml_doc)).each do |f|
            fields.push(f)
            break if multivalue == false && reduce.nil?
          end
        rescue
          fields = []
        end
        fields
      end

      def get_default_values(selector)
        selector.key?(:default_values) ? selector[:default_values] : ['']
      end

      def format_text(field)
        field.respond_to?(:text) ? field.text : field
      end

      def format_field(selector, field)
        formatted = selector.key?(:format) ? selector[:format].call(field) : format_text(field) rescue format_text(field)
        formatted = strip_invalid_utf8_bytes(formatted)
        formatted.strip! if formatted.respond_to?(:strip!)
        formatted.gsub!(@multiple_whitespace, ' ') if formatted.respond_to?(:gsub!)
        formatted
      end

      def format_fields(selector, fields, reduce = nil)
        formatted = fields.map { |f| format_field(selector, f) }.flatten
        formatted = [reduce.call(formatted)] unless reduce.nil?
        selector[:unique] ? formatted.uniq : formatted
      end

      def create_solr_fields(iso_xml_doc, selector)
        selector[:xpaths].each do |xpath|
          fields = eval_xpath(iso_xml_doc, xpath, selector[:multivalue], selector[:reduce])

          # stop evaluating xpaths once we find data in one of them
          if fields.size > 0 && fields.any? { |f| strip_invalid_utf8_bytes(f.text).strip.length > 0 }
            return format_fields(selector, fields, selector[:reduce])
          end
        end
        format_fields(selector, get_default_values(selector))
      end

      def translate(iso_xml_doc)
        solr_xml_doc = Nokogiri::XML::Builder.new do |xml|
          xml.doc_ do
            build_fields(xml, iso_xml_doc)
          end
        end
        solr_xml_doc.doc
      end

      def build_fields(xml, iso_xml_doc)
        @fields.each do |field_name, selector|
          create_solr_fields(iso_xml_doc, selector).each do |value|
            if value.is_a? Array
              value.each do |v|
                xml.field_({ name: field_name }, v) unless v.nil? || v.eql?('')
              end
            else
              xml.field_({ name: field_name }, value) unless value.nil? || value.eql?('')
            end
          end
        end
      end

      def strip_invalid_utf8_bytes(text)
        if text.respond_to?(:encode) && (!text.valid_encoding?)
          text.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        end

        text.gsub!("\u00BF", '') if text.respond_to?(:gsub!)

        text
      end
    end
  end
end
