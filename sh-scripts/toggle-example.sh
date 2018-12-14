printf "\nToggling current mode ...\n"

$ssh_cmd "[[ \"\$(php ${app_dir}/bin/magento deploy:mode:show)\" =~ production ]] && { 
    php ${app_dir}/bin/magento deploy:mode:set developer;
    echo first;
  } || { 
    php ${app_dir}/bin/magento deploy:mode:set production;
    echo 2nd; 
  }"
