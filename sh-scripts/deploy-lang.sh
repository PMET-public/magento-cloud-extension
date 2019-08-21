msg Finding available languages ...

ssh_cmd=$(get_interactive_ssh_cmd ${project} ${environment})

$ssh_cmd "
  # find languages
  find vendor -name language.xml -exec perl -ne '/<code>(.*)<\/code>/ and print \"\$1\n\"' {} \; | \
    # fix invalid lang codes
    perl -pe 's/zh_CN/zh_Hans_CN/;s/sr_SP/sr_Cyrl_RS/;s/zh_TW/zh_Hant_TW/' | \
    # remove duplicates
    sort -u
  read -p 'Choose language code to deploy: ' lang_code 
  php ./bin/magento setup:static-content:deploy --ansi --no-interaction -f --jobs $(nproc) -s standard \${lang_code}
  echo Cleaning layout cache ...
  php ./bin/magento cache:clean layout
"
