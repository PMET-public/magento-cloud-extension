msg "Rebuilding env ..."

tmp_git_dir="/tmp/delete-me-${project}-${environment}"
rm -rf "${tmp_git_dir}" # ensure tmp_git_dir doesn't exist from a previously aborted cmd 
git clone --branch "${environment}" $(${cli_path} project:info -p "${project}" git) "${tmp_git_dir}"
cd "${tmp_git_dir}"
date > .force-env-rebuild
git add -f .force-env-rebuild
git commit -m "force env rebuild"
git push
rm -rf "${tmp_git_dir}" # clean up
