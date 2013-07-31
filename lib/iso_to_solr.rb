require 'nokogiri'
require 'date'
require './lib/selectors.rb'

# Translates ISO nokogiri documents into solr nokogiri documents using a hash driver object (selectors.rb)
class ADEIsoToSolr

  ISO_NAMESPACES = { 'gmd' => 'http://www.isotc211.org/2005/gmd',  'gco' => 'http://www.isotc211.org/2005/gco' }

  attr_accessor :fields

  def initialize (selector)
    @fields = SELECTORS[selector]
  end

  def parse_xpath (iso_xml_doc, xpath, multivalue)
    field_value = []
    begin
      iso_xml_doc.xpath(xpath, ISO_NAMESPACES).each do |f|
        field_value.push(f.text)
        break if multivalue == false
      end
    rescue
      field_value = []
    end
    field_value
  end

  def get_field_default_value(xpath_selectors)
    default_value = nil
    if xpath_selectors.has_key?(:default_value)
      default_value = xpath_selectors[:default_value]
    else
      default_value = ''
    end
    default_value
  end

  def format_field(xpath_selectors, field)
    formatted_field = field
    if xpath_selectors.has_key?(:format)
      begin
        formatted_field = xpath_selectors[:format].call(field)
      rescue
        return field
      end
    end
    formatted_field
  end

  def get_field_values (iso_xml_doc, xpath_selectors)
    field_value = []
    xpath_selectors[:xpaths].each do |xpath|
      field_value = parse_xpath(iso_xml_doc, xpath, xpath_selectors[:multivalue])
      break if field_value[0] != nil
    end
    if field_value[0] == nil
      field_value.push(get_field_default_value(xpath_selectors))
    end
    format_field(xpath_selectors, field_value)
  end

  def translate (iso_xml_doc)
    solr_xml_doc = Nokogiri::XML::Builder.new do |xml|
      xml.doc_ do
        @fields.each do |field_name, xpath_selectors|
          get_field_values(iso_xml_doc, xpath_selectors).each do |value|
            xml.field_({ name: field_name }, value)
          end
        end
      end
    end
    solr_xml_doc.doc
  end

end
