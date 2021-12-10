# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Adding Fresh Market website ..."
msg "Attempting legacy install"

$cmd_prefix "
  php $app_dir/bin/magento gxd:datainstall StoryStore_Grocery --load=website
"
msg "Attempting updated install"
$cmd_prefix "
  php $app_dir/bin/magento gxd:datainstall MagentoEse_VerticalDataGrocery
"
msg "Fresh Market website available at ${base_url}fresh"
