Dir["./lib/selectors/*.rb"].each {|file| require file }

SELECTORS = {
	cisl: CISL,
	eol:  EOL
}