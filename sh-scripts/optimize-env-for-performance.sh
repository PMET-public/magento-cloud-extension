# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

# when bundling, don't merge https://devdocs.magento.com/guides/v2.3/frontend-dev-guide/themes/js-bundling.html
# static signing should be enabled https://devdocs.magento.com/guides/v2.3/config-guide/cache/static-content-signing.html

$cmd_prefix "
  php $app_dir/bin/magento config:set dev/static/sign 1
  php $app_dir/bin/magento config:set dev/js/enable_js_bundling 1
  php $app_dir/bin/magento config:set dev/js/minify_files 0
  php $app_dir/bin/magento config:set dev/js/merge_files 0
  php $app_dir/bin/magento config:set dev/css/merge_css_files 1
  php $app_dir/bin/magento config:set dev/css/minify_files 0
"
