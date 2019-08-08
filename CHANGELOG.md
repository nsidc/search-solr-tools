## Unreleased

  - Update dataset-catalog-services URL to only fetch current (*not*-retired)
    metadata records.
  - Add a few more gem release notes to README.

## v4.0.1 (2019-07-08)

  - Update CHANGELOG and release instructions.
  - Fix README typo.

## v4.0.0 (2019-07-08)

Changes:

  - Update spatial field formatting to work with Solr 8.1.1.

## v3.11.0 (2019-06-10)

Changes:

  - Update Ruby, Nokogiri, RestClient, Rubocop, and Webmock versions to address
    security warnings.
  - Update syntax as necessary for new versions of Rubocop and RestClient.

## v3.10.0 (2017-04-10)

Changes

  - Constrain ADC and ECHO feeds to only fetch records in the arctic.

Note
  - v3.9.1 and v3.10.0 were mistakenly released after version 3.9.0 was
    tagged. All three versions are identical, although v3.9.0 was never
    released to rubygems.org.

## v3.8.4 (2017-03-30)

Bugfix

  - Fix deleting old records after harvest for ADE auto suggest.

## v3.8.3 (2017-03-29)

Bugfix

  - Add dependency on ffi-geos to fix issue where `RGeo::Geos.factory` returned
    `nil` on Ubuntu 14 when parsing the BCO-DMO feed.

## v3.8.2 (2017-03-29)

Bugfix

  - Update NOAA WDS Paleo feed URL to use https.

## v3.8.1 (2017-03-29)

Bugfix

  - Fix BCO-DMO harvester to only fail when there are issues with individual
    records if `--die-on-failure` is given.

## v3.8.0 (2017-03-28)

Changes

  - Change ECHO harvester to harvest 100 records at a time, rather than 1000 to
    avoid timeout/hanging issues with the large requests.
  - Change "CISL"/ACADIS Gateway harvester to "NSF Arctic Data Center";
    aoncadis.org redirects to another site, and the data center's name was
    changed. The feed format was also changed; the harvester was updated to
    consume the new feed.

Bugfixes

  - Update NODC feed URL to use https.
  - Update RDA feed URL to use https.
  - Update handling of geometries to match new format provided by BCO-DMO feed.
  - Update NMI feed URL; the feed was relocated.
  - Harvesting tDAR starts from record 0 instead of record 1.
  - tDAR harvester no longer attempts to obtain another page of records after
    all the records have been harvested; where other feeds return an empty
    response that our harvester handles without issue, tDAR throws an error if
    the "startRecord" parameter is higher than their last record.
  - Exit with a non-0 status when a problem with the whole feed is encountered,
    even if `--die-on-failure` is not passed. That flag should only cause
    failures when there are issues with individual records; we don't want
    harvesting to stop due to a metadata issue with a small number of
    records.
  - Include BCO-DMO URL in the harvester output the same way all the other URLs
    are displayed.

## v3.7.1 (2016-05-18)

  - RuboCop fixes.

## v3.7.0 (2016-05-18)

New Features

  - Add sponsored programs to NSIDC harvesting.
  - Add support for ingesting Data Access Links from NSIDC JSON

Bugfixes

  - Fix dependency issue with gem "listen".
  - Fix bad configuration for OAI feed URLs.

## v3.5.1 (2016-02-15)

Bugfixes

  - Add temporal duration facet for GTN-P data center.

## v3.5.0 (2016-02-11)

Changes

  - Update long name for GTN-P data center.

## v3.4.0 (2016-02-11)

New Features

  - Add harvester for GTN-P.

## v3.3.4 (2016-02-08)

See v3.4.0.

## v3.3.3 (2016-01-14)

Bugfix

  - Added quote checking for cisl offset parsing check

## v3.3.1 (2015-09-25)

Bugfix

  - Remove strange facet string for temporal duration from NOAA Paleo search
    results.

## v3.3.0 (2015-09-24)

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
