#!/usr/bin/env bash

set -e
# set -x


proj_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."

# get the most recently created app dir
get_scripts_by_id() {
  local id="$1"
  node -e "$(< "$proj_dir/app/scripts/popup/commands-data.js");console.log(JSON.stringify(commands))" |
    jq --arg id "$id" -r -c '.[] | select( .id == $id ) | .scriptsInValue[]' |
    xargs
}

is_CI() {
  [[ "$GITHUB_WORKSPACE" ]]
}

create_script_from_command_id() {
  local command_id="$1" script scripts_to_join
  script="$(mktemp)"
  chmod u+x "$script"
  if is_CI; then
    scripts_to_join="$(get_scripts_by_id "$command_id" | tr ' ' ',')"
    curl -sS "https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/$GITHUB_SHA/sh-scripts/{$scripts_to_join}" > "$script"
  else
    pushd "$proj_dir/sh-scripts" > /dev/null || exit
    # shellcheck disable=SC2046
    cat $(get_scripts_by_id "$command_id") > "$script"
    popd > /dev/null
  fi
  echo "$script"
}