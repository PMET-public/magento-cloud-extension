msg Deploying all languages ...

$ssh_cmd "
  LANGS=\$(find vendor -name language.xml -exec perl -ne '/<code>(.*)<\/code>/ and print \"\$1\n\"' {} \; | \
    sort -u)
  php ./bin/magento setup:static-content:deploy --ansi --no-interaction -f --jobs $(nproc) -s standard \${LANGS}
"