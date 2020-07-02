require 'spec_helper'
require 'search_solr_tools/helpers/iso_to_solr'

describe SearchSolrTools::Helpers::IsoToSolr do
  describe '#strip_invalid_utf8_bytes' do
    def strip_invalid_utf8_bytes(text)
      described_class.new(nil).send(:strip_invalid_utf8_bytes, text)
    end

    it 'does not mess with floats' do
      expect(strip_invalid_utf8_bytes(2.0)).to eql 2.0
    end

    it 'does not modify plain characters' do
      expect(strip_invalid_utf8_bytes('hello, world')).to eql 'hello, world'
    end

    it 'does not modify accented e characters' do
      expect(strip_invalid_utf8_bytes("\u00E9")).to eql "\u00E9"
    end

    it 'removes inverted question marks' do
      expect(strip_invalid_utf8_bytes("\u00BF")).to eql ''
    end

    it 'removes invalid UTF-8 characters' do
      expect(strip_invalid_utf8_bytes("\xFF")).to eql ''
    end
  end

  describe 'nsdic ISO to Solr converter' do
    fixture = Nokogiri.XML File.open('spec/unit/fixtures/nsidc_iso.xml')
    iso_to_solr = described_class.new(:adc)

    it 'should use the default value if none of the xpaths are present' do
      selector = {
        xpaths: ['//gmd:fake1', '//gmd:fake2'],
        default_values: ['default value'],
        multivalue: false
      }
      field = iso_to_solr.create_solr_fields fixture, selector
      expect(field.size).to eql 1
      expect(field.first).to eql 'default value'
    end

    it 'should grab only one node when the multivalue option is false' do
      selector = {
        xpaths: ['//gmd:keyword/gco:CharacterString'],
        multivalue: false
      }
      keywords = iso_to_solr.create_solr_fields fixture, selector
      expect(keywords.size).to eql 1
    end

    it 'should grab all the nodes when the multivalue option is true' do
      selector = {
        xpaths: ['//gmd:keyword/gco:CharacterString'],
        multivalue: true
      }
      keywords = iso_to_solr.create_solr_fields fixture, selector
      expect(keywords.size).to eql 5
      expect(keywords.first).to eql 'Place'
    end

    it 'should fall over the second xpath when the first is not present' do
      selector = {
        xpaths: ['//gmd:YouWontFindThis', '//gmd:dataSetURI/gco:CharacterString'],
        multivalue: false
      }
      uri = iso_to_solr.create_solr_fields fixture, selector
      expect(uri.size).to eql 1
      expect(uri.first).to eql 'http://nsidc.org/data/test'
    end

    it 'should format the field using the format key if present' do
      selector = {
        xpaths: ['//gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString'],
        multivalue: false,
        format: proc { |x| x.text.upcase }
      }
      org = iso_to_solr.create_solr_fields fixture, selector
      expect(org.size).to eql 1
      expect(org.first).to eql 'NATIONAL SNOW AND ICE DATA CENTER'
    end

    it 'should return the same value if the format function breaks' do
      selector = {
        xpaths: ['//gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString'],
        multivalue: false,
        format: proc { |x| x[nil].upcase }
      }
      titles = iso_to_solr.create_solr_fields fixture, selector
      expect(titles.size).to eql 1
      expect(titles.first).to eql 'National Snow and Ice Data Center'
    end

    it 'should use the default_value array to create multiple fields if multivalue is set to true' do
      defaults = []
      defaults.push('default1')
      defaults.push('default2')
      selector = {
        xpaths: [''],
        default_values: defaults,
        multivalue: true
      }
      sources = iso_to_solr.create_solr_fields fixture, selector
      expect(sources.size).to eql 2
      expect(sources[0]).to eql 'default1'
      expect(sources[1]).to eql 'default2'
    end

    it 'should not include blank fields when the selector does not match any values' do
      SearchSolrTools::Helpers::SELECTORS[:fake] = {
        fake: {
          xpaths: ['//gmd:fakeSelector/gco:CharacterString'],
          multivalue: false
        }
      }

      translated = described_class.new(:fake).translate fixture
      expect(translated.xpath('.//fake').size).to eql 0
    end

    it 'should return the default value when the node has no value' do
      SearchSolrTools::Helpers::SELECTORS[:fake] = {
        fake: {
          xpaths: ['.//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString'],
          multivalue: false,
          default_values: ['Fake Org']
        }
      }
      translated = described_class.new(:fake).translate fixture
      expect(translated.xpath('.//field[@name=\'fake\']').text).to eql 'Fake Org'
    end

    it 'should reduce multiple values to one when :reduce is set' do
      selector = {
        xpaths: ['//gmd:pointOfContact'],
        multivalue: false,
        reduce: proc { |values| values.max }
      }
      points_of_contact = iso_to_solr.create_solr_fields(fixture, selector)
      expect(points_of_contact).to eq ["User Services NASA DAAC at the National Snow and Ice Data Center NASA DAAC custodian"]
    end
  end
end
