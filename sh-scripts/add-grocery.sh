# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Adding new grocery vertical ..."

[[ "$(which composer)" ]] || error "Composer is not installed. You must install composer to continue. https://getcomposer.org/download/"

tmp_git_dir="$(mktemp -d)"
git clone --branch "$environment" "$project@git.demo.magento.cloud:$project.git" "$tmp_git_dir"
cd "$tmp_git_dir" || exit
git config user.email "chrome-extension@email.com"
git config user.name "chrome-extension"
export COMPOSER_PROCESS_TIMEOUT=600 COMPOSER_MEMORY_LIMIT=-1 
composer update magentoese/module-data-install magento/services-connector --ignore-platform-reqs
composer config repositories.grocery git git@github.com:PMET-public/module-storystore-grocery.git
composer require story-store/grocery:dev-demo --ignore-platform-reqs
git add composer.*
git commit -m "Adding Grocery"
git push
rm -rf "$tmp_git_dir" # clean up
