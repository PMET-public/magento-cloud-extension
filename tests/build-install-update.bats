#!/usr/bin/env ./tests/libs/bats/bin/bats

# bats will loop indefinitely with debug mode on (i.e. set -x)
unset debug

load 'libs/bats-assert/load'
load 'libs/bats-support/load'
load 'libs/bats-file/load'

load 'bats-lib.sh'


setup() {
  shopt -s nocasematch
}

@test 'dev-build' {
  cd "$GITHUB_WORKSPACE"
  npm install
  run ./node_modules/gulp/bin/gulp.js dev-build
  assert_success
  assert_output -e "finished.*dev-build"
}

@test 'clean' {
  run ./node_modules/gulp/bin/gulp.js clean
  assert_success
  assert_output -e "finished.*clean"
}

@test 'dist-build' {
  run ./node_modules/gulp/bin/gulp.js dist-build
  assert_success
  assert_output -e "finished.*dist-build"
}

@test 'package' {
  run ./node_modules/gulp/bin/gulp.js package
  assert_success
  assert_output -e "finished.*package"
  assert_file_exist ./package/mcm-chrome-ext.zip
}

@test 'clean 2' {
  run ./node_modules/gulp/bin/gulp.js clean
  assert_success
  assert_output -e "finished.*clean"
  assert_dir_not_exist dist
  assert_dir_not_exist .tmp
}

@test 'update-extension' {
  script="$(create_script_from_command_id update-extension)"
  run "$script" 3>&-
  assert_success
  assert_output -e "mcm-chrome-ext.zip.*inflating"
}
