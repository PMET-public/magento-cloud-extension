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
  export tab_url="https://demo.magento.cloud/projects/$PROJECT_ID/environments/test-env-for-mce"
  export ext_ver="$(get_ext_version)"
}

@test 'run-cron' {
  run bash <(cat $(get_scripts_by_id run-cron))
  assert_success
  assert_output -e "Ran jobs by schedule.*Ran jobs by schedule"
}

@test 'reindex' {
  run bash <(cat $(get_scripts_by_id reindex))
  assert_success
  assert_output -e "been invalidated.*rebuilt successfully"
}
