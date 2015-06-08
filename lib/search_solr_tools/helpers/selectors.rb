require_relative '../selectors/ade_cisl'
require_relative '../selectors/ade_eol'
require_relative '../selectors/ade_nmi'
require_relative '../selectors/echo_iso'
require_relative '../selectors/ices_iso'
require_relative '../selectors/nodc_iso'
require_relative '../selectors/pdc_iso'
require_relative '../selectors/ade_rda'
require_relative '../selectors/tdar_opensearch'
require_relative '../selectors/usgs_iso'

# This hash grabs all the selector files inside the selectors directory,
# to add a new source we need to create a selector file and add it to this hash.
SELECTORS = {
  cisl:   CISL,
  echo:   ECHO,
  eol:    EOL,
  ices:   ICES,
  nmi:    NMI,
  nodc:   NODC,
  pdc:    PDC,
  rda:    RDA,
  tdar:   TDAR,
  usgs:   USGS
}
