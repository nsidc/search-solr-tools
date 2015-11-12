## v3.3.1

Bugfix

  - Remove strange facet string for temporal duration from NOAA Paleo search
    results.

## v3.3.0

New Features

  -  Add harvest support for
   [NOAA Paleoclimatology Data Center (NOAA Paleo)](https://www.ncdc.noaa.gov/data-access/paleoclimatology-data/datasets).

  -  Add harvest support for
   [Data Observation Network for Earth (Data ONE)](https://www.dataone.org/). [Pivotal 77763710](https://www.pivotaltracker.com/story/show/77763710)

## v3.2.1 (2015-09-23)

Bugfixes

  - Catch a timeout error earlier in the stack to prevent an infinite loop of
    retries; this bug caused the PDC harvester to attempt to access the feed 150
    times, instead of simply failing after 3 failed
    attempts. [Pivotal 103057378](https://www.pivotaltracker.com/story/show/103057378)

Changes

  - Change NODC harvester's default page size from 100 to 50. The NODC feed is
    responding with HTTP 500 when requesting records 301-400, but not when
    requesting 301-350 or 351-400.

## v3.2.0 (2015-07-01)

New Features

  - Add `harvest` support for
    [Rolling Deck to Repository (R2R)](http://get.rvdata.us/services/cruise/)
  - Add subcommands `-v` and `--version` to display the installed version of the
    gem

## v3.1.2 (2015-06-30)

Changes

  - Gem is available via [RubyGems](https://rubygems.org)

## v3.1.1 (2015-06-29)

Bugfixes

  - Updated deletion constraints such that lucene special characters in
    dataset names do not cause deletion of that data provider's data to fail.

## v3.1.0 (2015-06-25)

Features

  - Remove gi-cat as a dependency as no harvesters utilize it.
  - Harvest the UCAR NCAR - Earth Observing Laboratory (UCAR/NCAR EOL) from
    EOL's THREDDS endpoint instead of GI-Cat
  - Harvest the Norwegian Meteorological Institute feed directly instead of via
    GI-Cat.

Bugfixes

  - Fix broken configuration, where production was attempting to use the Blue,
    rather than the the production, Solr host for harvesting. (see PCT-410)

## v3.0.1 (2015-06-18)

Bugfixes

  - Fix broken `delete_all` commands.

## v3.0.0 (2015-06-15)

  - Packaged as a gem with a new executable file, providing a new interface to
    harvest feeds into solr.
  - Change the RDA and EOL harvesters to store the data center name as "UCAR
    NCAR", rather than "UCAR/NCAR". This fixes a bug with deleting the datasets;
    the query to Solr was failing because the "/" character could not be
    correctly escaped.

## v2.0.0 (2015-06-08)

  - Upgrade from Ruby version 1.9.3 to 2.2.2
  - Compliant with
    [RuboCop v0.32.0](https://github.com/bbatsov/rubocop/releases/tag/v0.32.0)

## v1.1.0 (2015-06-05)

Features

  - Add support to harvest RDA directly from their feed, rather than through
    GI-Cat.

## v1.0.0 (2015-06-02)

Bugfixes

  - Fix missing accented characters in datasets from Polar Data Catalogue

## v0.4.0 (2015-02-25)

Features

  - Added TDAR translator for harvesting into Solr
  - Added PDC (Polar Data Catalog) translator for harvesting int Solr
  - Revised CISL endpoint to harvest a subset of data. Created translator to harvest directly rather than through GI-Cat

Bugfixes

  - Fixed USGS harvesting issue where it was timing out on specific records
  - Fixed EOL translator for processing spatial bounds properly
  - Validate bounding boxes for documents being added to Solr

## v0.2.0 (2015-02-19)

Bugfixes

  - Set USGS page size from 100 to 10 to reduce Solr load
  - Added exception handling for REST POSTs to Solr

## v0.0.2 (2015-02-11)

Features

  - Updated project to use new CI tools and processes
