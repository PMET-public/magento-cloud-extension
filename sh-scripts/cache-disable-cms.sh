# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

$cmd_prefix "php $app_dir/bin/magento cache:disable layout block_html full_page"
