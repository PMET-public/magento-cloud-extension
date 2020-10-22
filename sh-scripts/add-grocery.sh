msg "Adding new grocery vertical ..."

tmp_git_dir="$(mktemp -d)"
git clone --branch "$environment" "$project@git.demo.magento.cloud:$project.git" "$tmp_git_dir"
cd "$tmp_git_dir"
composer update magentoese/module-data-install --ignore-platform-reqs
composer config repositories.grocery git git@github.com:PMET-public/module-storystore-grocery.git
composer require story-store/grocery:dev-demo --ignore-platform-reqs
git add composer.*
git commit -m "Adding Grocery"
git push
rm -rf "$tmp_git_dir" # clean up