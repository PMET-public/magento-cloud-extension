msg Deploying all languages ...

$ssh_cmd "
  # find languages
  LANGS=\$(find vendor -name language.xml -exec perl -ne '/<code>(.*)<\/code>/ and print \"\$1\n\"' {} \; | \
    # fix invalid lang codes
    perl -pe 's/zh_CN/zh_Hans_CN/;s/sr_SP/sr_Cyrl_RS/;s/zh_TW/zh_Hant_TW/' | \
    # remove duplicates
    sort -u)
  php ./bin/magento setup:static-content:deploy --ansi --no-interaction -f --jobs $(nproc) -s standard \${LANGS}
  php ./bin/magento cache:clean layout
"
