printf "\nTurning on production mode ...\n"

$ssh_cmd "php ${app_dir}/bin/magento deploy:mode:set production"
