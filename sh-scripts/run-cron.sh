
printf "\nRunning cron jobs ...\n"
$ssh_cmd "php ${home_dir}/bin/magento cron:run; php ${home_dir}/bin/magento cron:run"
