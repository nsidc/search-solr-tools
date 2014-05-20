# NSIDC Solr

This is a collection of:

* Ruby files and rake tasks to transform ISO into SOLR documents
* Rake tasks to harvest NSIDC and ADE data

## Working on the Project

Be sure to run `bundle install`.

To set up and run your local instance of Solr, run:

* `rake build:setup`
* `rake server:start`


Manipulating data in Solr can be done with the `harvest` tasks.

* `rake harvest:all` retrieves and inserts data for both NSIDC search and the Arctic Data Explorer.
* `rake harvest:all_ade` gathers data for the Arctic Data Explorer and inserts it into Solr.
* `rake harvest:nsidc_json` will gather data for NSIDC search.
* `rake harvest:delete_all` wipes out the database in your local Solr.


The style checker RuboCop can be run with `rubocop` or `rake guard:rubocop`. The rake task will also watch for ruby files (.rb, .rake, Gemfile, Guardfile, Rakefile) to be changed, and run RuboCop on the changed files.

`rake guard` will automatically run the unit tests and RuboCop in one terminal window.

Pushing with failing tests or RuboCop violations will cause the Jenkins build to break. Jenkins jobs to build and deply this project are named "NSIDC_Search_SOLR_()…" and can be viewed under the [NSIDC Search tab](https://scm.nsidc.org/jenkins/view/NSIDC%20Search/).

### Testing

Unit tests can be run with `rspec`, `rake spec:unit`, or `rake guard:specs`.
Running the rake guard task will also automatically run the tests whenever the appropriate files are changed.

Running the acceptance tests locally requires a running instance of Solr and some data indexed:

* Use the Solr dev VM at https://bitbucket.org/nsidc/nsidc-solr-development-vm.  Follow the instructions in that project to get the VM started and running.
* `vagrant ssh` into the VM
* Clone this project, run `bundle install`
* Run `rake server:start` to start up Solr
* It was suggested that running the `rake build:setup` would have taken care of this...
* Run `rake restart_with_clean_nsidc_harvest` to suck in the NSIDC metadata (FIXME I had to run this a couple of times to get it to work...)
* Once Solr has its data, `rake spec:acceptance` runs the ATs.
