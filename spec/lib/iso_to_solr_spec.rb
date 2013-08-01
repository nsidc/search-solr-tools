require 'iso_to_solr'

describe 'CISL ISO to Solr converter' do

  fixture = Nokogiri.XML File.open('spec/fixtures/cisl_iso.xml')
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
    keywords.first.should be == "\nLand cover\n"
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

end
