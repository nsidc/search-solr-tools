#!/usr/bin/env bash

#load RVM and .rvmrc file
[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"
[[ -s "$WORKSPACE/.rvmrc" ]] && source "$WORKSPACE/.rvmrc"

set -x
set -e
bundle install
