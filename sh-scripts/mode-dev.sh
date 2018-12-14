printf "\nTurning on developer mode ...\n"

$ssh_cmd "php ${app_dir}/bin/magento deploy:mode:set developer"
