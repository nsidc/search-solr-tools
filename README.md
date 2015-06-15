# NSIDC Search Solr Tools

This is a gem that contains:

* Ruby translators to transform various metadata feeds into solr documents
* A command-line utility to access/utilize the gem's translators to harvest
   metadata into a working solr instance.

## Working on the Project

Be sure to run `bundle install`. If you encounter errors running `rake`, first
try using `bundle exec rake` to be sure you are using the right version of Rake.

To use this project, you will need a local instance of Solr 4.3, which can be
downloaded from
[Apache's archive](https://archive.apache.org/dist/lucene/solr/4.3.0/). At
NSIDC, the development VM can be provisioned with the
[solr puppet module](https://bitbucket.org/nsidc/puppet-solr/) to install and
configure Solr. Alternatively, the
[search-solr](https://bitbucket.org/nsidc/search-solr/) project, which contains
puppetry to install solr and any other dependencies, as well some necessary
config files like `schema.xml`, can be used.

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

### RuboCop

The style checker [RuboCop](https://github.com/bbatsov/rubocop) can be run with
`rubocop` or `rake guard:rubocop`. The rake task will also watch for ruby files
(.rb, .rake, Gemfile, Guardfile, Rakefile) to be changed, and run RuboCop on the
changed files.

`rake guard` will automatically run the unit tests and RuboCop in one terminal
window.

RuboCop can be configured by modifying `.rubocop.yml`.

Pushing with failing tests or RuboCop violations will cause the Jenkins build to
break. Jenkins jobs to build and deply this project are named
"NSIDC_Search_SOLR_()…" and can be viewed under the
[NSIDC Search tab](https://scm.nsidc.org/jenkins/view/NSIDC%20Search/).

### Testing

Unit tests can be run with `rspec`, `rake spec:unit`, or `rake guard:specs`.
Running the rake guard task will also automatically run the tests whenever the
appropriate files are changed.

Running the acceptance tests locally requires a running instance of Solr and
some data indexed:

* Use the [Solr dev VM](https://bitbucket.org/nsidc/dev-vm-search). Follow the
  instructions in that project to get the VM started and running.
* `vagrant ssh` into the VM
* Clone this project, run `bundle install`
* Run `rake build:setup`
* Run `rake server:start` to start up Solr
* Run `rake dev:restart_with_clean_nsidc_harvest` to suck in the NSIDC metadata
* Once Solr has its data, `rake spec:acceptance` runs the ATs.

## Organization Info

### How to contact NSIDC

User Services and general information:  
Support: http://support.nsidc.org  
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
