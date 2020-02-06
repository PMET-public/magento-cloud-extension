$cmd_prefix "
  php bin/magento config:set dev/js/enable_js_bundling 1
  php bin/magento config:set dev/js/minify_files 1
  php bin/magento config:set dev/js/merge_files 1
"
