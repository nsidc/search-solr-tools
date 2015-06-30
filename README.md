[![Build Status](https://travis-ci.org/nsidc/search-solr-tools.svg?branch=master)](https://travis-ci.org/nsidc/search-solr-tools)

# NSIDC Search Solr Tools

This is a gem that contains:

* Ruby translators to transform various metadata feeds into solr documents
* A command-line utility to access/utilize the gem's translators to harvest
   metadata into a working solr instance.

## Using the project

### Standard Installation

The gem is available through [RubyGems](https://rubygems.org/). To install the
gem, ensure all requirements below are met and run (providing the appropriate
version):

`sudo gem install search_solr_tools -v $VERSION`

### Custom Deployment

Clone the repository, and install all requirements as noted below.

#### Configuration

Once you have the code and requirements, edit the configuration file in
`lib/search_solr_tools/config/environments.yaml` to match your environment. The
configuration values are set by environment for each harvester (or specified in
the `common` settings list), with the environment overriding `common` if a
different setting is specified for a given environment.

Each harvester has its own configuration settings. Most are the target endpoint;
EOL, however, has a list of THREDDS project endpoints and NSIDC has its own
oai/metadata endpoint settings.

Most users should not need to change the harvester configuration unless they
establish a local test node, or if a provider changes available endpoints;
however, the `host` option for each environment must specify the configured SOLR
instance you intend to use these tools with.

#### Build and Install Gem

Then run:

  `bundle exec gem build ./search_solr_tools.gemspec`

Once you have the gem built in the project directory, install the utility:

  `gem install --local ./search_solr_tools-version.gem`

## Working on the Project

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Stage your changes (`git add`)
3. Commit your Rubocop compliant and test-passing changes with a
   [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
  (`git commit`)
4. Push to the branch (`git push -u origin my-new-feature`)
5. Create a new Pull Request

### Requirements

* Ruby > 2.0.0
* [Bundler](http://bundler.io/)
* Requirements for nokogiri:
    * [libxml2/libxml2-dev](http://xmlsoft.org/)
    * [zlibc](http://www.zlibc.linux.lu/)
    * [zlib1g/zlib1g-dev](http://zlib.net/)
    * Dependency build requirements:
        * For Ubuntu/Debian, install the build-essential package.
        * On the latest Fedora release installing the following will get you all of the requirements:

              `yum groupinstall 'Development Tools'`

              `yum install gcc-c++`

        *Please note*:  If you are having difficulty installing Nokogiri please review the
          Nokogiri [installation tutorial](http://www.nokogiri.org/tutorials/installing_nokogiri.html)

* All gems installed (preferably using bundler: `bundle install`)
* A running, configured SOLR instance to accept data harvests.

### RuboCop

The style checker [RuboCop](https://github.com/bbatsov/rubocop) can be run with
`rubocop` or `bundle exec rake guard:rubocop`. The rake task will also watch for
ruby files (.rb, .rake, Gemfile, Guardfile, Rakefile) to be changed, and run
RuboCop on the changed files.

`bundle exec rake guard` will automatically run the unit tests and RuboCop in
one terminal window.

RuboCop can be configured by modifying `.rubocop.yml`.

Pushing with failing tests or RuboCop violations will cause the Jenkins build to
break. Jenkins jobs to build and deploy this project are named
"NSIDC_Search_SOLR_()…" and can be viewed under the
[NSIDC Search tab](https://scm.nsidc.org/jenkins/view/NSIDC%20Search/).

### Testing

Unit tests can be run with `rspec`, `bundle exec rake spec:unit`, or `bundle
exec rake guard:specs`.  Running the rake guard task will also automatically run
the tests whenever the appropriate files are changed.

Please be sure to run them in the `bundle exec` context if you're utilizing bundler.

### Creating Releases (NSIDC devs only)

Requirements:

* Ruby > 2.0.0
* [Bundler](http://bundler.io/)
* [Gem Release](https://github.com/svenfuchs/gem-release)
* [Rake](https://github.com/ruby/rake)
* a [RubyGems](https://rubygems.org) account that has
  [ownership](http://guides.rubygems.org/publishing/) of the gem
* RuboCop and the unit tests should all pass (`rake`)

**gem release** is used by rake tasks in this project to handle version changes,
tagging, and publishing to RubyGems.

| Command                   | Description |
|---------------------------|-------------|
| `rake release:pre[false]` | Increase the current prerelease version number, push changes |
| `rake release:pre[true]`  | Increase the current prerelease version number, publish release\* |
| `rake release:none`       | Drop the prerelease version, publish release, then `pre[false]` |
| `rake release:minor`      | Increase the minor version number, publish release, then `pre[false]` |
| `rake release:major`      | Increase the major version number, publish release, then `pre[false]` |

\*"publish release" means each of the following occurs:

* a new tag is created
* the changes are pushed
* the tagged version is built and published to RubyGems

### SOLR:

To harvest data utilizing the gem, you will need a local configured instance of
Solr 4.3, which can be downloaded from
[Apache's archive](https://archive.apache.org/dist/lucene/solr/4.3.0/).

#### NSIDC

At NSIDC the development VM can be provisioned with the
[solr puppet module](https://bitbucket.org/nsidc/puppet-solr/) to install and
configure Solr.

#### Non-NSIDC

Outside of NSIDC, setup solr using the instructions found in the
[search-solr](https://github.com/nsidc/search-solr) project.

### Harvesting Data

The harvester requires additional metadata from services that may not yet be
publicly available, which are referenced in
`lib/search_solr_tools/config/environments.yaml`.

To utilize the gem, build and install the **search_solr_tools** gem. This will
add an executable `search_solr_tools` to the path (source is in
`bin/search_solr_tools`). The executable is self-documenting; for a brief
overview of what's available, simply run `search_solr_tools`.

Harvesting of data can be done using the `harvest` task, giving it a list of
harvesters and an environment. Deletion is possible via the `delete_all` and/or
`delete_by_data_center'`tasks. `list harvesters` will list the valid harvest
targets.

In addition to feed URLs, `environments.yaml` also defines various environments
which can be modified, or additional environments can be added by just adding a
new YAML stanza with the right keys; this new environment can then be used with
the `--environment` flag when running `search_solr_tools harvest`.

## Organization Info

### How to contact NSIDC

User Services and general information:  
Support: [http://support.nsidc.org](http://support.nsidc.org)  
Email: nsidc@nsidc.org

Phone: +1 303.492.6199  
Fax: +1 303.492.2468

Mailing address:  
National Snow and Ice Data Center  
CIRES, 449 UCB  
University of Colorado  
Boulder, CO 80309-0449 USA

### License

Every file in this repository is covered by the GNU GPL Version 3; a copy of the
license is included in the file COPYING.

### Citation Information

Andy Grauch, Brendan Billingsley, Chris Chalstrom, Danielle Harper, Ian
Truslove, Jonathan Kovarik, Luis Lopez, Miao Liu, Michael Brandt, Stuart Reed
(2013): Arctic Data Explorer SOLR Search software tools. The National Snow and
Ice Data Center. Software. http://ezid.cdlib.org/id/doi:10.7265/N5JQ0XZM
