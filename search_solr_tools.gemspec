$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'search_solr_tools/version'

# no need for tests or dev files like .rubocop.yml to be packaged with the gem
gem_files = %(CHANGELOG.md COPYING README.md bin/ lib/ search_solr_tools.gemspec)

Gem::Specification.new do |spec|
  spec.name          = 'search_solr_tools'
  spec.version       = SearchSolrTools::VERSION
  spec.authors       = ['Chris Chalstrom', 'Michael Brandt', 'Jonathan Kovarik', 'Luis Lopez', 'Stuart Reed', 'Julia Collins', 'Scott Lewis']
  spec.email         = ['Jonathan.Kovarik@colorado.edu', 'luis.lopezespinosa@colorado.edu', 'collinsj@colorado.edu', 'scott.lewis@colorado.edu']
  spec.summary       = 'Tools to harvest and manage various scientific dataset feeds in a Solr instance.'
  spec.description   = <<-EOF
    Ruby translators to transform various metadata feeds into solr documents and
    a command-line utility to access/utilize the gem's translators to harvest
    metadata into a working solr instance.
  EOF
  spec.homepage      = 'https://github.com/nsidc/search-solr-tools'
  spec.license       = 'GPL-3.0-or-later'

  spec.files         = `git ls-files -z #{gem_files}`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 3.2.2'

  spec.add_runtime_dependency 'ffi-geos', '~> 2.4.0'
  spec.add_runtime_dependency 'iso8601', '~> 0.13.0'
  spec.add_runtime_dependency 'logging', '~> 2.3.1'
  spec.add_runtime_dependency 'multi_json', '~> 1.15.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.15.4'
  spec.add_runtime_dependency 'rest-client', '~> 2.1.0'
  spec.add_runtime_dependency 'rgeo', '~> 3.0.0'
  spec.add_runtime_dependency 'rgeo-geojson', '~> 2.1.1'
  spec.add_runtime_dependency 'rsolr', '~> 2.5.0'
  spec.add_runtime_dependency 'thor', '~> 1.2.2'

  spec.add_development_dependency 'bump', '~> 0.10.0'
  spec.add_development_dependency 'gem-release', '~> 2.2.2'
  spec.add_development_dependency 'guard', '~> 2.18.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'guard-rubocop', '~> 1.5.0'
  spec.add_development_dependency 'listen', '3.8.0'
  spec.add_development_dependency 'rake', '~> 13.0.6'
  spec.add_development_dependency 'rspec', '~> 3.12.0'
  spec.add_development_dependency 'rubocop', '~> 1.54.2'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.22.0'
  spec.add_development_dependency 'webmock', '~> 3.18.1'
end
