msg "Finding available languages. May take a minute ..."

$cmd_prefix "
  cd $app_dir/vendor
  # find languages in known directories
  find magento community-engineering splendidinternet -name language.xml -exec perl -ne '/<code>(.*)<\/code>/ and print \"\$1\n\"' {} \; 2> /dev/null | \
    # fix invalid lang codes
    perl -pe 's/zh_CN/zh_Hans_CN/;s/sr_SP/sr_Cyrl_RS/;s/zh_TW/zh_Hant_TW/' | \
    # remove duplicates
    sort -u
  "

echo "
^^ Which language code to deploy? Must be entered EXACTLY as displayed."
read lang_code < "$read_input_src"


$cmd_prefix "php bin/magento store:list"

echo "
^^ Which store code to deploy? (Must be 'Code' not 'ID' - e.g. default)"
read store_code < "$read_input_src"

if [[ "$lang_code" =~ ^[a-zA-Z] && "$store_code" =~ ^[a-zA-Z] ]]; then
  $cmd_prefix "
    cd $app_dir
    php bin/magento setup:static-content:deploy --ansi --no-interaction -f --jobs $(nproc) -s standard $lang_code
    php bin/magento config:set general/locale/code $lang_code --scope=store --scope-code=$store_code
    echo Cleaning layout cache ...
    php bin/magento cache:clean layout
  "
else
  echo "$lang_code sc $store_code"
  error "Invalid selections."
fi
