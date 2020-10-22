#!/usr/bin/env bash

set -e
# set -x


proj_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."

# get the most recently created app dir
get_scripts_by_id() {
  local id="$1"
  node -e "$(< "$proj_dir/app/scripts/popup/commands-data.js");console.log(JSON.stringify(commands))" |
    jq --arg id "$id" -r -c '.[] | select( .id == $id ) | .scriptsInValue[]'
}

get_ext_version() {
  jq -r -c ".version" "$proj_dir/app/manifest.json"
}
