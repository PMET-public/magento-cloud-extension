# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

# run with -tt for color output
$cmd_prefix -tt '
  for i in $(
    vendor/bin/mr sys:cron:list --format=csv |
    grep -v -E "^cron_test_job" |
    grep -v -E "^paradoxlabs_authnetcim_account_updater" |
    sed "1d;s/,.*//" \
  ); do
    echo "Running: vendor/bin/mr sys:cron:run $i"
    vendor/bin/mr sys:cron:run $i
  done
'
