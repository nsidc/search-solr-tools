# NSIDC Solr

This is a collection of:

* Ruby files and rake tasks to transform ISO into Solr documents
* Rake tasks to harvest NSIDC and ADE data

## Working on the Project

Be sure to run `bundle install`. If you encounter errors running `rake`, first
try using `bundle exec rake` to be sure you are using the right version of Rake.

To use this project, you will need a local instance of Solr 4.3, which can be
downloaded from
[Apache's archive](https://archive.apache.org/dist/lucene/solr/4.3.0/). At
NSIDC, the development VM can be provisioned with the
[solr puppet module](https://bitbucket.org/nsidc/puppet-solr/) to install and
configure Solr.

### Harvesting Data

For only NSIDC results, run the task `rake
dev:restart_with_clean_nsidc_harvest`. To harvest multiple collections, do these
steps:

* `rake build:setup`
* `rake dev:deploy_schema`
* `rake dev:restart`
* `rake harvest:delete_all`
* Harvest the feeds you want here.

The above is what `rake dev:restart_with_clean_nsidc_harvest` does, with the
last step being a `rake harvest:nsidc_json`.

Manipulating data in Solr can be done with the `harvest` tasks.

* `rake harvest:all` retrieves and inserts data for both NSIDC search and the
  Arctic Data Explorer and deletes old documents.
* `rake harvest:all_ade` gathers data for the Arctic Data Explorer, inserts it
  into Solr, and deletes old documents.
* `rake harvest:nsidc_json` will gather data for NSIDC search and delete old
  documents.
* `rake harvest:delete_all` wipes out the database in your local Solr.

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
