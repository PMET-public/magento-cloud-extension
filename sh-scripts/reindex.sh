printf "\nReindexing ...\n"

$ssh_cmd "php ${app_dir}/bin/magento indexer:reset; php ${app_dir}/bin/magento indexer:reindex"
