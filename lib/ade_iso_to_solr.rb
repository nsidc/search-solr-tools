require 'nokogiri'

# Translates ISO nokogiri documents into solr nokogiri documents
class ADEIsoToSolr

  SELECTORS = {
    cisl: {
      authoritative_id: {
          xpaths: ['//gmd:fileIdentifier/gco:CharacterString'],
          default_value: '',
          multivalue: false
        },
      title: {
          xpaths: ['//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString'],
          default_value: '',
          multivalue: false
        },
      summary: {
          xpaths: ['//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString'],
          default_value: '',
          multivalue: false
        },
      data_center: {
          xpaths: ['//gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString'],
          default_value: '',
          multivalue: false
        },
      parameters: {
          xpaths: [''],
          default_value: '',
          multivalue: false
        },
      topics: {
          xpaths: [''],
          default_value: '',
          multivalue: false
        },
      parameters: {
          xpaths: [''],
          default_value: '',
          multivalue: false
        },
      keywords: {
          xpaths: ['//gmd:keyword/gco:CharacterString'],
          default_value: '',
          multivalue: true
        },
    },
    eol: {
    }
  }

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

  def get_field_values (iso_xml_doc, xpath_selectors)
    field_value = []
    xpath_selectors[:xpaths].each do |xpath|
      field_value = parse_xpath(iso_xml_doc, xpath, xpath_selectors[:multivalue])
      break if field_value[0] != nil
    end
    if field_value[0] == nil
      field_value.push(xpath_selectors[:default_value])
    end
    field_value
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