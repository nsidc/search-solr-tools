# Load modules and classes
hiera_include('classes')

# If using bumpversion (python) for your version bumping
# needs, you can uncomment this to get bumpversion and
# fabric (python task runner)
if $environment == 'ci' {
  class { 'python':
    version => 'system',
    pip     => true,
    dev     => true # Needed for fabric
  }

  python::pip { 'bumpversion':
    pkgname => 'bumpversion',
    ensure  => '0.5',
    owner   => 'root'
  }

  # Task runner for python
  python::pip { 'fabric':
    pkgname => 'fabric',
    ensure  => '1.10',
    owner   => 'root'
  }
}

# Ensure the brightbox apt repository gets added before installing ruby
include apt
apt::ppa{'ppa:brightbox/ruby-ng':}

package { 'ruby2.2':
  ensure => present,
  require => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
} ->
package { 'ruby2.2-dev':
  ensure => present
} ->
exec { 'install bundler':
  command => 'sudo gem install bundler -v 1.10.3',
  path => '/usr/bin'
} ->

# nokogiri 'build native' dep
package { 'zlib1g-dev':
  ensure => present
}
