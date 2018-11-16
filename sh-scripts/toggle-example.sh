printf "\nToggling current mode ...\n"

$ssh_cmd "[[ \"\$(php ${home_dir}/bin/magento deploy:mode:show)\" =~ production ]] && { 
    php ${home_dir}/bin/magento deploy:mode:set developer;
    echo first;
  } || { 
    php ${home_dir}/bin/magento deploy:mode:set production;
    echo 2nd; 
  }"
