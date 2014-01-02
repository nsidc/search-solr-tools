require 'nokogiri'
require 'date'
require './lib/selectors.rb'

# Translates ISO nokogiri documents into solr nokogiri documents using a hash driver object
# This class should be constructed passing the selector file hash as a parameter (see selectors.rb)
# after creating an instance we call transtale with a nokogiri iso document as a parameter.

class IsoToSolr
  def initialize(selector)
    @fields = SELECTORS[selector]
    @multiple_whitespace = /\s{2,}/ # save the regex so it is not recompiled every time format_field() is called
  end

  def eval_xpath(iso_xml_doc, xpath, multivalue)
    fields = []
    begin
      iso_xml_doc.xpath(xpath, IsoNamespaces.get_namespaces(iso_xml_doc)).each do |f|
        fields.push(f)
        break if multivalue == false
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
    formatted.strip! if formatted.respond_to?(:strip!)
    formatted.gsub!(@multiple_whitespace, ' ') if formatted.respond_to?(:gsub!)
    formatted
  end

  def format_fields(selector, fields)
    formatted = fields.map { |f| format_field(selector, f) }.flatten
    selector[:unique] ? formatted.uniq : formatted
  end

  def create_solr_fields(iso_xml_doc, selector)
    selector[:xpaths].each do |xpath|
      fields = eval_xpath(iso_xml_doc, xpath, selector[:multivalue]) # this will return a nodeset with all the elements that matched the xpath
      return format_fields(selector, fields) if fields.size > 0 && fields.any? { |f| f.text.strip.length > 0 }
    end
    format_fields(selector, get_default_values(selector))
  end

  def translate(iso_xml_doc)
    solr_xml_doc = Nokogiri::XML::Builder.new do |xml|
      xml.doc_ do
        @fields.each do |field_name, selector|
          create_solr_fields(iso_xml_doc, selector).each do |value|
            xml.field_({ name: field_name }, value) unless value.nil? || value.eql?('')
          end
        end
      end
    end
    solr_xml_doc.doc
  end

end
