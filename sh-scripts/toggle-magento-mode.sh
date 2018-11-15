printf "\nFlushing cache ...\n"

$ssh_cmd '[[ $(php bin/magento deploy:mode:show) =~ production ]] && { 
    echo production; 
    echo first; 
  } || { 
    echo developer; 
    echo 2nd; 
  }'
