# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Rebuilding env ..."

tmp_git_dir="$(mktemp -d)"
git clone --branch "$environment" $($cli_path project:info -p "$project" git) "$tmp_git_dir"
cd "$tmp_git_dir"
date > .force-env-rebuild
git add -f .force-env-rebuild
git commit -m "force env rebuild"
git push
rm -rf "$tmp_git_dir" # clean up
