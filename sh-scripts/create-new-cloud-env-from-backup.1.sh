# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Creating new cloud env from backup ..."

# must use "declare -a" b/c some array items are quoted strings with spaces
declare -a "projects=($($cli_path projects --format=tsv --no-header --columns=id,title | perl -pe 's/\t/\t\"/;s/\s+$/\"\n/'))"
if [[ ${#projects[@]} -lt 1 ]]; then
  error "No projects found. Is your Magento Cloud CLI installed and logged in?"
fi

local_tar_file=$(choose_backup) || exit 1
environment="${local_tar_file%.tar}-$(date "+%m-%d-%H-%M")"

project=$(dialog --clear \
  --backtitle "Destination Project Selection" \
  --title "Your Project(s)" \
  --menu "Choose a project for the new env:" \
  $menu_height $menu_width $num_visible_choices "${projects[@]}" \
  2>&1 > "$output_src")
clear

# clone master
"$cli_path" get "$project" -e master "$environment"
cd "$environment"
git checkout -b "$environment"
tar -xf "${local_tar_file}" --strip-components=1
# comment out deploy cmds
perl -i -pe 'if (/^\s+deploy:/../^\s+post_deploy:/) {s/^(\s+)/$1#/ if !/deploy:\s+\|/}' .magento.app.yaml
# commit all changes
git add -u .
git commit -m "restore files"
git push --set-upstream magento "$environment"
"$cli_path" environment:activate -p "$project" -e "$environment"

exit

ssh_url=$(get_ssh_url "$project" "$environment")

disable_cron "$ssh_url"

transfer_local_tar_to_remote "$ssh_url" "${local_tar_file}"

restore_files_from_tar "$ssh_url" "${local_tar_file}"

enable_maintenance_mode  "$ssh_url"

restore_db_from_tar "$ssh_url" "${local_tar_file}"

if is_cloud; then
  tmp_git_dir=$(echo "${local_tar_file}" | perl -pe 's!^!/tmp/!;s!.tar$!!')
  # extract tar file to tmp dir and make git repo to push to cloud
  msg "Extract tar locally and create git repo to forcefully push containing updated composer.* files"
  rm -rf "$tmp_git_dir" # ensure tmp_git_dir doesn't exist from a previously aborted cmd
  mkdir -p "$tmp_git_dir"
  tar -xf "${backups_dir}/${local_tar_file}" -C "$tmp_git_dir" "${app_dir#'/'}"
  cd "${tmp_git_dir}${app_dir}"
  git init
  git remote add cloud $("$cli_path" project:info -p "$project" git)
  git checkout -b "$environment"
  git add .
  git add -f auth.json
  git commit -m "Creating from backup: ${local_tar_file}"
  git push -f -u cloud "$environment"
fi

restore_media_from_backup_server "$ssh_url"

clean_cache "$ssh_url"

enable_cron "$ssh_url"

disable_maintenance_mode  "$ssh_url"