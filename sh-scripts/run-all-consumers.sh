# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

$cmd_prefix "
  for i in \$(php bin/magento queue:consumers:list); do { bin/magento queue:consumers:start --max-messages 9999 \$i &  sleep 10; } done
"
