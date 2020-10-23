#!/usr/bin/env ./tests/libs/bats/bin/bats

# bats will loop indefinitely with debug mode on (i.e. set -x)
unset debug

load 'libs/bats-assert/load'
load 'libs/bats-support/load'
load 'libs/bats-file/load'

load 'bats-lib.sh'


setup() {
  shopt -s nocasematch
  cd "$proj_dir/sh-scripts" || exit
  export tab_url="https://demo.magento.cloud/projects/$MCE_PROJECT_ID/environments/test-env-for-mce"
  export ext_ver="$GITHUB_SHA"
}

@test 'admin-unlock' {
  script="$(create_script_from_command_id admin-unlock)"
  run "$script" 3>&- << RESPONSES

RESPONSES
  assert_success
  assert_output -e "admin.*unlock"
}

@test 'run-cron' {
  script="$(create_script_from_command_id run-cron)"
  run "$script" 3>&-
  assert_success
  assert_output -e "Ran jobs by schedule.*Ran jobs by schedule"
}

@test 'reindex' {
  script="$(create_script_from_command_id reindex)"
  run "$script" 3>&-
  assert_success
  assert_output -e "been invalidated.*rebuilt successfully"
}
