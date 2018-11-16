printf "\nTurning on developer mode ...\n"

$ssh_cmd "php ${home_dir}/bin/magento deploy:mode:set developer"
