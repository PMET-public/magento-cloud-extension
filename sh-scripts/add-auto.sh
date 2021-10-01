# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Adding new automotive vertical ..."

$cmd_prefix "
  php $app_dir/bin/magento gxd:datainstall MagentoEse_VerticalDataAuto
"
msg "Auto website available at "$base_url"auto";
