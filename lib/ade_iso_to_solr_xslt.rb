  SELECTORS = {
    cisl: {
      authoritative_id: {
          xpaths: ['.//gmd:fileIdentifier/gco:CharacterString'],
          default_value: '',
          multivalue: false
        },
      title: {
          xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString'],
          default_value: '',
          multivalue: false
        },
      summary: {
          xpaths: ['.//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString'],
          default_value: '',
          multivalue: false
        },
      data_centers: {
          xpaths: ['.//gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString'],
          default_value: '',
          multivalue: false
        },
      authors: {
          xpaths: [''],
          default_value: '',
          multivalue: true
        },
      keywords: {
          xpaths: ['.//gmd:keyword/gco:CharacterString'],
          default_value: '',
          multivalue: true
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
      platforms: {
          xpaths: [''],
          default_value: '',
          multivalue: false
        },
      sensors: {
          xpaths: [''],
          default_value: '',
          multivalue: true
        },
      last_revision_date: {
          # xpaths: ['//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date', '//gmd:dateStamp'],
          xpaths: [''],
          default_value: '', # DateTime.now.to_s,
          multivalue: false
        },
      dataset_url: {
          xpaths: ['.//gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL'],
          default_value: '',
          multivalue: false
        },
      source: {
          xpaths: [''],
          default_value: 'ADE',
          multivalue: false
        },
    },
    eol: {
    }
  }
