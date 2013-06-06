#!/usr/bin/env bash

usage()
{
    echo "Usage: ${0##*/} {start|stop|restart} {integration|qa|staging|production}"
    exit 1
}
# absolute path to this script directory (without script name)
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_PATH

#load RVM and .rvmrc file
[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"
[[ -s "./.rvmrc" ]] && source "./.rvmrc"
set -x
set -e

if [ -z "$2" ]
then
  ENV="integration"
elif [["$2" eq "qa"]] || ["$2" eq "staging"] || ["$2" eq "production"]]
then
  ENV="$2"
else
  echo "Invalid envorinment $2 specified, please try again"
  usage
fi


if [["$1" eq "start"] || ["$1" eq "restart"]]
then
   bundle exec rake stop_solr[$ENV]
   bundle exec rake start_solr[$ENV]
elif ["$1" eq "stop"]
then
   bundle exec rake stop_solr[$ENV]
else
   usage
fi


