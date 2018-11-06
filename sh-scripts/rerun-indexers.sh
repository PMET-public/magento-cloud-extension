
$SSH_CMD -p $project -e $environment 'php bin/magento indexer:reset; php bin/magento indexer:reindex'
