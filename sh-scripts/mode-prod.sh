printf "\nTurning on production mode ...\n"

$ssh_cmd "php ${home_dir}/bin/magento deploy:mode:set production"
