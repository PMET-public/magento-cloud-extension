$cmd_prefix "
  php ${app_dir}/bin/magento config:set dev/js/enable_js_bundling 1
  php ${app_dir}/bin/magento config:set dev/js/minify_files 1
  php ${app_dir}/bin/magento config:set dev/js/merge_files 1
  php ${app_dir}/bin/magento config:set dev/css/merge_css_files 1
  php ${app_dir}/bin/magento config:set dev/css/minify_files 1
"
