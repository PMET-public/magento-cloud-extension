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
  export tab_url="https://demo.magento.cloud/projects/$MCE_PROJECT_ID/environments/$GITHUB_RUN_ID"
  export ext_ver="$GITHUB_SHA"
}


@test 'add-grocery' {
  script="$(create_script_from_command_id add-grocery)"
  run "$script" 3>&-
  assert_success
  # assert_output -e ""
}

@test 'admin-create' {
  script="$(create_script_from_command_id admin-create)"
  run "$script" 3>&- << RESPONSES
admin2
123123q
admin@test.com
RESPONSES
  assert_success
  assert_output -e "created.*user"
}

@test 'delete-env' {
  script="$(create_script_from_command_id delete-env)"
  run "$script" 3>&- << RESPONSES
y
RESPONSES
  assert_success
  assert_output -e "branch.*deleted"
}
