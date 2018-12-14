printf "\nRunning cron jobs ...\n"

$ssh_cmd "php ${app_dir}/bin/magento cron:run; php ${app_dir}/bin/magento cron:run"
