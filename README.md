[![Gem Version](https://badge.fury.io/rb/search_solr_tools.svg)](http://badge.fury.io/rb/search_solr_tools)

# NSIDC Search Solr Tools

This is a gem that contains:

* Ruby translators to transform NSIDC metadata feeds into solr documents
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
`lib/search_solr_tools/config/environments.yaml` to match your environment. 
Environment settings take precedence over `common` settings.
The `host` option for each environment must specify the configured SOLR
instance you intend to use these tools with.

#### Build and Install Gem

Run:

  `bundle exec gem build ./search_solr_tools.gemspec`

Once you have the gem built in the project directory, install it:

  `gem install --local ./search_solr_tools-version.gem`

See _Harvesting Data_ (below) for usage examples.

## Working on the Project

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Stage your changes (`git add`)
3. Commit your Rubocop compliant and test-passing changes with a
   [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
  (`git commit`)
4. Push to the branch (`git push -u origin my-new-feature`)
5. Create a new Pull Request

### Requirements

* Ruby > 3.2.2
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

### Testing

Unit tests can be run with `rspec`, `bundle exec rake spec:unit`, or `bundle
exec rake guard:specs`.  Running the rake guard task will also automatically run
the tests whenever the appropriate files are changed.

Please be sure to run them in the `bundle exec` context if you're utilizing bundler.

By default, tests are run with minimal logging - no log file and only fatal errors
written to the console.  This can be changed by setting the environment variables 
as described in [Logging](#logging) below.

### Creating Releases (NSIDC devs only)

Requirements:

* Ruby > 3.2.2
* [Bundler](http://bundler.io/)
* [Rake](https://github.com/ruby/rake)
* RuboCop and the unit tests should all pass (`rake`)

To make a release, follow these steps:

1. Confirm no errors are returned by `bundle exec rubocop` *
2. Confirm all tests pass (`bundle exec rake spec:unit`) *
3. Ensure that the `CHANGELOG.md` file is up to date with an `Unreleased`
   header.
4. Submit a Pull Request
5. Once the PR has been reviewed and approved, merge the branch into `main`
6. On your local machine, ensure you are on the `main` branch (and have
   it up-to-date), and run `bundle exec rake bump:<part>` (see below)
   * This will trigger the GitHub Actions CI workflow to push a release to
     RubyGems.

The steps marked `*` above don't need to be done manually; every time a commit
is pushed to the GitHub repository, these tests will be run automatically.

The first 4 steps above are self-explanatory.  More information on the last
steps can be found below.

#### Version Bumping

Running the `bundle exec rake bump:<part>` tasks will do the following actions:

1. The gem version will be updated locally
2. The `CHANGELOG.md` file will updated with the updated gem version and date
3. A tag `vx.x.x` will be created (with the new gem version)
4. The files updated by the bump will be pushed to the GitHub repository, along
   with the newly created tag.

The sub-tasks associated with bump will allow the type of bump to be determined:

| Command                   | Description                                                                                        |
|---------------------------|----------------------------------------------------------------------------------------------------|
| `rake bump:pre`           | Increase the current prerelease version number (v1.2.3 -> v1.2.3.pre1; v1.2.3.pre1 -> v1.2.3.pre2) |
| `rake bump:patch`         | Increase the current patch number (v1.2.0 -> v1.2.1; v1.2.4 -> v1.2.4)                             |
| `rake bump:minor`         | Increase the minor version number (v1.2.0 -> v1.3.0; v1.2.4 -> v1.3.0)                             |
| `rake bump:major`         | Increase the major version number (v1.2.0 _> v2.0.0; v1.2.4 -> v2.0.0)                             |

Using any bump other than `pre` will remove the `pre` suffix from the version as well.

#### Release to RubyGems

When a tag in the format of `vx.y.z` (including a `pre` suffix) is pushed to GitHub,
it will trigger the GitHub Actions release workflow.  This workflow will:

1. Build the gem
2. Push the gem to RubyGems

The CI workflow has the credentials set up to push to RubyGems, so no user intervention
is needed, and the workflow itself does not have to be manually triggered.

If needed, the release can also be done locally by running the command
`bundle exec gem release`. In order for this to work, you will need to have a
local copy of current Rubygems API key for the _NSIDC developer user_ account in
To get the lastest API key:

`curl -u <username> https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials; chmod 0600 ~/.gem/credentials`

It is recommended that this not be run locally, however; use the GitHub Actions CI
workflow instead.

### SOLR

To harvest data utilizing the gem, you will need an installed instance of [Solr](https://solr.apache.org/guide/solr/latest/index.html)

#### NSIDC

At NSIDC the development VM can be provisioned with the
[solr puppet module](https://bitbucket.org/nsidc/puppet-nsidc-solr/) to install and
configure Solr.

#### Non-NSIDC

Outside of NSIDC, setup solr using the instructions found in the
[search-solr](https://github.com/nsidc/search-solr) project.

### Harvesting Data

The harvester requires additional metadata from services that may not be
publicly available, which are referenced in
`lib/search_solr_tools/config/environments.yaml`.

To utilize the gem, build and install the **search_solr_tools** gem. This will
add an executable `search_solr_tools` to the path (source is in
`bin/search_solr_tools`). The executable is self-documenting; for a brief
overview of what's available, simply run `search_solr_tools`.

Harvesting of data can be done using the `harvest` task, giving it a list of
harvesters and an environment. Deletion is possible via the `delete_all` and/or
`delete_by_data_center'`tasks. `list_harvesters` will list the valid harvest
targets.

In addition to feed URLs, `environments.yaml` also defines various environments
which can be modified, or additional environments can be added by just adding a
new YAML stanza with the right keys; this new environment can then be used with
the `--environment` flag when running `search_solr_tools harvest`.

An example harvest of NSIDC metadata into a developer instance of Solr:

    bundle exec search_solr_tools harvest --data-center=nsidc --environment=dev

In this example, the `host` value in the `environments.yaml` `dev` entry
must reference a valid Solr instance.

#### Logging

By default, when running the harvest, harvest logs are written to the file
`/var/log/search-solr-tools.log` (set to `warn` level), as well as to the console
at `info` level.  These settings are configured in the `environments.yaml` config
file, in the `common` section. 

The keys in the `environments.yaml` file to consider are as follows:

* `log_file` - The full name and path of the file to which log output will be written
  to.  If set to the special value `none`, no log file will be written to at all.
  Log output will be **appended** to the file, if it exists; otherwise, the file will
  be created.
* `log_file_level` - Indicates the level of logging which should be written to the log file.
* `log_stdout_level` - Indicates the level of logging which should be written to the console.
  This can be different than the level written to the log file.

You can also override the configuration file settings at the command line with the
following environment variables (useful when for doing development work):

* `SEARCH_SOLR_LOG_FILE` - Overrides the `log_file` setting
* `SEARCH_SOLR_LOG_LEVEL` - Overrides the `log_file_level` setting
* `SEARCH_SOLR_STDOUT_LEVEL` - Overrides the `log_stdout_level` setting

When running the spec tests, `SEARCH_SOLR_LOG_FILE` is set to `none` and
`SEARCH_SOLR_STDOUT_LEVEL` is set to `fatal`, unless you manually set those
environment variables prior to running the tests.  This is to keep the test output
clean unless you need more detail for debugging.

The following are the levels of logging that can be specified.  These levels are
cumulative; for example, `error` will also output `fatal` log entries, and `debug`
will output **all** log entries.

* `none` - No logging outputs will be written.
* `fatal` - Only outputs errors which result in a crash.
* `error` - Outputs any error that occurs while harvesting.
* `warn` - Outputs warnings that occur that do not cause issues with the harvesting,
  but might indicate things that may need to be addressed (such as deprecations, etc)
* `info` - Outputs general information, such as harvesting status
* `debug` - Outputs detailed information that can be used for debugging and code tracing.

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
Truslove, Jonathan Kovarik, Luis Lopez, Miao Liu, Michael Brandt, Stuart Reed,
Julia Collins, Scott Lewis (2023): Arctic Data Explorer SOLR Search software tools.
The National Snow and Ice Data Center. Software. https://doi.org/10.7265/n5jq0xzm
