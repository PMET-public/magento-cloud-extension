# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Adding new grocery vertical ..."

$cmd_prefix "
  php $app_dir/bin/magento gxd:datainstall StoryStore_Grocery --load=website
"
msg "Grocery website available at "$base_url"fresh";
