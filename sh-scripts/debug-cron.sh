# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

# run with -tt for color output
$cmd_prefix -tt '
  # do you still have to invoke it twice?
  for i in $(vendor/bin/mr sys:cron:list --format=csv | sed 's/,.*//'); do echo "Running: vendor/bin/mr sys:cron:run $i"; vendor/bin/mr sys:cron:run $i; done
'
