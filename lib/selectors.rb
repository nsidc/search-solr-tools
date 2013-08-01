Dir['./lib/selectors/*.rb'].each { |file| require file }

# This hash grabs all the selector files inside the selectors directory,
# to add a new source we need to create a selector file and add it to this hash.

SELECTORS = {
  cisl: CISL,
  eol:  EOL,
  nsidc: NSIDC
}