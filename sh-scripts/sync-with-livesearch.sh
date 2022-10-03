# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

echo "Switching search engine..."

tmp_git_dir="$(mktemp -d)"

git clone --branch "$environment" "$project@git.demo.magento.cloud:$project.git" "$tmp_git_dir"
cd "$tmp_git_dir"
config_file="$tmp_git_dir/app/etc/config.php"
grep -q "'Magento_LiveSearch' => 1," "$config_file" && ls_enabled="true"
git merge --abort || :
parent="$("$cli_path" environment:info -p "$project" -e "$environment" parent)"
git merge --strategy-option theirs "origin/$parent"

if "$ls_enabled"; then
  perl -i -pe "s/'Magento_LiveSearch' => 0/'Magento_LiveSearch' => 1/" "$config_file"
  perl -i -pe "s/'Magento_LiveSearchAdapter' => 0/'Magento_LiveSearchAdapter' => 1/" "$config_file"
  perl -i -pe "s/'Magento_LiveSearchStorefrontPopover' => 0/'Magento_LiveSearchStorefrontPopover' => 1/" "$config_file"
  perl -i -pe "s/'Magento_LiveSearchMetrics' => 0/'Magento_LiveSearchMetrics' => 1/" "$config_file"
  perl -i -pe "s/'Magento_LiveSearchTerms' => 0/'Magento_LiveSearchTerms' => 1/" "$config_file"
  perl -i -pe "s/'Magento_Elasticsearch' => 1/'Magento_Elasticsearch' => 0/" "$config_file"
  perl -i -pe "s/'Magento_Elasticsearch6' => 1/'Magento_Elasticsearch6' => 0/" "$config_file"
  perl -i -pe "s/'Magento_Elasticsearch7' => 1/'Magento_Elasticsearch7' => 0/" "$config_file"
  perl -i -pe "s/'Magento_ElasticsearchCatalogPermissions' => 1/'Magento_ElasticsearchCatalogPermissions' => 0/" "$config_file"
  perl -i -pe "s/'Magento_InventoryElasticsearch' => 1/'Magento_InventoryElasticsearch' => 0/" "$config_file"
fi

git config user.email "chrome-extension@email.com"
git config user.name "chrome-extension"

# commit changes and push
git add "$config_file"
git commit -m "merged with $parent and re-enabled LS from chrome extension"
git push
rm -rf "$tmp_git_dir" # clean up
