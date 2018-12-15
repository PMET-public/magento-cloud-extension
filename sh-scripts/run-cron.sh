printf "\nRunning cron jobs ...\n"

$ssh_cmd "for i in \$(seq 60 -1 1); do
    php ${app_dir}/bin/magento cron:run; 
    echo \$i times remaining. Sleeping 1 min.;
    sleep 60; 
  done"
