# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

parent="$("$cli_path" environment:info -p "$project" -e "$environment" parent)"
echo "Syncing from $parent ..."

tmp_git_dir="$(mktemp -d)"

git clone --branch "$environment" "$project@git.demo.magento.cloud:$project.git" "$tmp_git_dir"
cd "$tmp_git_dir"
config_file="$tmp_git_dir/app/etc/config.php"
grep -q "'Magento_LiveSearch' => 1," "$config_file" && ls_enabled="true"
git merge --abort || :
git merge --strategy-option theirs "origin/$parent" --allow-unrelated-histories

if "$ls_enabled"; then
  perl -i -pe "s/'Magento_LiveSearch' => 0/'Magento_LiveSearch' => 1/" "$config_file"
  perl -i -pe "s/'Magento_LiveSearchAdapter' => 0/'Magento_LiveSearchAdapter' => 1/" "$config_file"
  perl -i -pe "s/'Magento_LiveSearchStorefrontPopover' => 0/'Magento_LiveSearchStorefrontPopover' => 1/" "$config_file"
  perl -i -pe "s/'Magento_LiveSearchMetrics' => 0/'Magento_LiveSearchMetrics' => 1/" "$config_file"
  perl -i -pe "s/'Magento_LiveSearchTerms' => 0/'Magento_LiveSearchTerms' => 1/" "$config_file"
  perl -i -pe "s/'Magento_LiveSearchProductListing' => 0/'Magento_LiveSearchProductListing' => 1/" "$config_file"
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
git commit -m "merged with $parent and re-enabled LS (if enabled) from chrome extension" || :
echo "Pushing any changes. This may take a few min. You can monitor the progress on your cloud projects page."
git push
rm -rf "$tmp_git_dir" # clean up

echo "Code sync complete."
echo "Sync data? This should only take a couple miniutes,$red BUT WILL OVERWRITE CUSTOMIZATIONS THAT YOU'VE MADE.$no_color"
read -r -n 1 -p "y/n?" < "$input_src" 2> "$output_src"
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  "$cli_path" environment:synchronize -p "$project" -e "$environment" -y data
else
  echo "Data sync skipped. If you later decide to overwrite just data, you can still use the cloud UI."
fi