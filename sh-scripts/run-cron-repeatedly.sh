# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Running cron jobs every min for 1 hr. Press control-c to cancel."

$cmd_prefix "for i in \$(seq 60 -1 1); do
    php $app_dir/bin/magento cron:run; 
    echo \$i times remaining. Sleeping 1 min.;
    sleep 60; 
  done"
