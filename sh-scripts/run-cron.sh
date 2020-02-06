$cmd_prefix "
  # do you still have to invoke it twice?
  php ${app_dir}/bin/magento cron:run
  php ${app_dir}/bin/magento cron:run
"
