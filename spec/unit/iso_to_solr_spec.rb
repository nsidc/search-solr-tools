require 'selectors/helpers/iso_to_solr'

describe 'IsoToSolr#strip_invalid_utf8_bytes' do
  def strip_invalid_utf8_bytes(text)
    IsoToSolr.new(nil).send(:strip_invalid_utf8_bytes, text)
  end

  it 'does not mess with floats' do
    strip_invalid_utf8_bytes(2.0).should eql 2.0
  end

  it 'does not modify plain characters' do
    strip_invalid_utf8_bytes('hello, world').should eql 'hello, world'
  end

  it 'does not modify accented e characters' do
    strip_invalid_utf8_bytes('é').should eql 'é'
  end

  it 'removes inverted question marks' do
    strip_invalid_utf8_bytes('¿').should eql ''
  end

  it 'removes invalid UTF-8 characters' do
    strip_invalid_utf8_bytes("\xFF").should eql ''
  end
end

describe 'CISL ISO to Solr converter' do
  fixture = Nokogiri.XML File.open('spec/unit/fixtures/cisl_iso.xml')
  iso_to_solr = IsoToSolr.new(:cisl)

  it 'should use the default value if none of the xpaths are present' do
    selector = {
          xpaths: ['//gmd:fake1', '//gmd:fake2'],
          default_values: ['default value'],
          multivalue: false
      }
    field = iso_to_solr.create_solr_fields fixture, selector
    field.size.should be == 1
    field.first.should be == 'default value'
  end

  it 'should grab only one node when the multivalue option is false' do
    selector = {
          xpaths: ['//gmd:keyword/gco:CharacterString'],
          multivalue: false
      }
    keywords = iso_to_solr.create_solr_fields fixture, selector
    keywords.size.should be == 1
  end

  it 'should grab all the nodes when the multivalue option is true' do
    selector = {
          xpaths: ['//gmd:keyword/gco:CharacterString'],
          multivalue: true
      }
    keywords = iso_to_solr.create_solr_fields fixture, selector
    keywords.size.should be == 9
    keywords.first.should be == 'Land cover'
  end

  it 'should fall over the second xpath when the first is not present' do
    selector = {
          xpaths: ['//gmd:YouWontFindThis', '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString'],
          multivalue: false
      }
    titles = iso_to_solr.create_solr_fields fixture, selector
    titles.size.should be == 1
    titles.first.should be == 'Carbon Isotopic Values of Alkanes Extracted from Paleosols'
  end

  it 'should format the field using the format key if present' do
    selector = {
          xpaths: ['//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString'],
          multivalue: false,
          format: proc { |x| x.text.upcase }
      }
    titles = iso_to_solr.create_solr_fields fixture, selector
    titles.size.should be == 1
    titles.first.should be == 'CARBON ISOTOPIC VALUES OF ALKANES EXTRACTED FROM PALEOSOLS'
  end

  it 'should return the same value if the format function breaks' do
    selector = {
          xpaths: ['//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString'],
          multivalue: false,
          format: proc { |x| x[nil].upcase }
      }
    titles = iso_to_solr.create_solr_fields fixture, selector
    titles.size.should be == 1
    titles.first.should be == 'Carbon Isotopic Values of Alkanes Extracted from Paleosols'
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
    sources.size.should be == 2
    sources[0].should be == 'default1'
    sources[1].should be == 'default2'
  end

  it 'should not include blank fields when the selector does not match any values' do
    SELECTORS[:fake] = {
      fake: {
        xpaths: ['//gmd:fakeSelector/gco:CharacterString'],
        multivalue: false
      }
    }

    translated = IsoToSolr.new(:fake).translate fixture
    translated.xpath('.//fake').size.should eql 0
  end

  it 'should return the default value when the node has no value' do
    SELECTORS[:fake] = {
      fake: {
          xpaths: ['.//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString'],
          multivalue: false,
          default_values: ['Fake Org']
      }
    }
    translated = IsoToSolr.new(:fake).translate fixture
    translated.xpath('.//field[@name=\'fake\']').text.should eql 'Fake Org'
  end

  it 'should reduce multiple values to one when :reduce is set' do
    selector = {
      xpaths: ['//gmd:keyword/gco:CharacterString'],
      multivalue: false,
      reduce: proc { |values| values.max }
    }
    keywords = iso_to_solr.create_solr_fields(fixture, selector)
    keywords.should eq ["Soils\n/\nCarbon"]
  end

end
