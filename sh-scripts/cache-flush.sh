printf "\nFlushing cache ...\n"

$ssh_cmd "php ${home_dir}/bin/magento cache:flush; rm -rf ${home_dir}/var/cache/* ${home_dir}/var/page_cache/*"
