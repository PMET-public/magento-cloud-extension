# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

echo "Switching search engine..."

tmp_git_dir="$(mktemp -d)"

git clone --branch "$environment" "$project@git.demo.magento.cloud:$project.git" "$tmp_git_dir"

cd "$tmp_git_dir"
filename="$tmp_git_dir"/app/etc/config.php
if grep -q "'Magento_LiveSearch' => 1," $filename; then
    message="Switching to ElasticSearch"
    perl -i -pe "s/'Magento_LiveSearch' => 1/'Magento_LiveSearch' => 0/" $filename
    perl -i -pe "s/'Magento_LiveSearchAdapter' => 1/'Magento_LiveSearchAdapter' => 0/" $filename
    perl -i -pe "s/'Magento_LiveSearchStorefrontPopover' => 1/'Magento_LiveSearchStorefrontPopover' => 0/" $filename
    perl -i -pe "s/'Magento_LiveSearchMetrics' => 1/'Magento_LiveSearchMetrics' => 0/" $filename
    perl -i -pe "s/'Magento_LiveSearchTerms' => 1/'Magento_LiveSearchTerms' => 0/" $filename
    perl -i -pe "s/'Magento_AdvancedSearch' => 0/'Magento_AdvancedSearch' => 1/" $filename
    perl -i -pe "s/'Magento_Elasticsearch' => 0/'Magento_Elasticsearch' => 1/" $filename
    perl -i -pe "s/'Magento_Elasticsearch6' => 0/'Magento_Elasticsearch6' => 1/" $filename
    perl -i -pe "s/'Magento_Elasticsearch7' => 0/'Magento_Elasticsearch7' => 1/" $filename
    perl -i -pe "s/'Magento_ElasticsearchCatalogPermissions' => 0/'Magento_ElasticsearchCatalogPermissions' => 1/" $filename
    perl -i -pe "s/'Magento_InventoryElasticsearch' => 0/'Magento_InventoryElasticsearch' => 1/" $filename
else
    message="Switching to LiveSearch"
    perl -i -pe "s/'Magento_LiveSearch' => 0/'Magento_LiveSearch' => 1/" $filename
    perl -i -pe "s/'Magento_LiveSearchAdapter' => 0/'Magento_LiveSearchAdapter' => 1/" $filename
    perl -i -pe "s/'Magento_LiveSearchStorefrontPopover' => 0/'Magento_LiveSearchStorefrontPopover' => 1/" $filename
    perl -i -pe "s/'Magento_LiveSearchMetrics' => 0/'Magento_LiveSearchMetrics' => 1/" $filename
    perl -i -pe "s/'Magento_LiveSearchTerms' => 0/'Magento_LiveSearchTerms' => 1/" $filename
    perl -i -pe "s/'Magento_AdvancedSearch' => 1/'Magento_AdvancedSearch' => 0/" $filename
    perl -i -pe "s/'Magento_Elasticsearch' => 1/'Magento_Elasticsearch' => 0/" $filename
    perl -i -pe "s/'Magento_Elasticsearch6' => 1/'Magento_Elasticsearch6' => 0/" $filename
    perl -i -pe "s/'Magento_Elasticsearch7' => 1/'Magento_Elasticsearch7' => 0/" $filename
    perl -i -pe "s/'Magento_ElasticsearchCatalogPermissions' => 1/'Magento_ElasticsearchCatalogPermissions' => 0/" $filename
    perl -i -pe "s/'Magento_InventoryElasticsearch' => 1/'Magento_InventoryElasticsearch' => 0/" $filename
fi
msg $message

git config user.email "chrome-extension@email.com"
git config user.name "chrome-extension"

# commit changes and push
git add $filename
git commit -m "$message"
git push
rm -rf "$tmp_git_dir" # clean up
