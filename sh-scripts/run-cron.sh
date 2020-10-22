# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

$cmd_prefix "
  # do you still have to invoke it twice?
  php $app_dir/bin/magento cron:run
  php $app_dir/bin/magento cron:run
"
