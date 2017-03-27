require 'require_all'
require_rel '../selectors'

module SearchSolrTools
  module Helpers
    # This hash grabs all the selector files inside the selectors directory,
    # to add a new source we need to create a selector file and add it to this hash.
    SELECTORS = {
      adc:         Selectors::ADC,
      data_one:    Selectors::DATA_ONE,
      echo:        Selectors::ECHO,
      ices:        Selectors::ICES,
      nmi:         Selectors::NMI,
      ncdc_paleo:  Selectors::NCDC_PALEO,
      nodc:        Selectors::NODC,
      pdc:         Selectors::PDC,
      r2r:         Selectors::R2R,
      rda:         Selectors::RDA,
      tdar:        Selectors::TDAR,
      usgs:        Selectors::USGS
    }
  end
end
