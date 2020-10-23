# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Flushing cache ..."

$cmd_prefix "
  php $app_dir/bin/magento cache:flush
  rm -rf $app_dir/var/cache/* $app_dir/var/page_cache/*
"
