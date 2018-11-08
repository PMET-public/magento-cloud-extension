
printf "\nReindexing ...\n"
$ssh_cmd "php ${home_dir}/bin/magento indexer:reset; php ${home_dir}/bin/magento indexer:reindex"
