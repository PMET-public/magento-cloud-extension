msg Creating new cloud env from backup ...

# must use "declare -a" b/c some array items are quoted strings with spaces
declare -a "projects=($(${cli_path} projects --format=tsv --no-header --columns=id,title | perl -pe 's/\t/\t\"/;s/\s+$/\"\n/'))"
if [[ ${#projects[@]} -lt 1 ]]; then
  error No projects found. Is your Magento Cloud CLI installed and logged in?
fi

local_tar_file=$(choose_backup) || exit 1

project=$(dialog --clear \
  --backtitle "Destination Project Selection" \
  --title "Your Project(s)" \
  --menu "Choose a project for the new env:" \
  $menu_height $menu_width $num_visible_choices "${projects[@]}" \
  2>&1 >/dev/tty)
clear

tmp_git_dir=$(echo "${local_tar_file}" | perl -pe 's!^!/tmp/!;s!.tar$!!')
environment="${local_tar_file%.tar}"

set_db_vars

# if env already exists in project, then exit with error
if "${cli_path}" environment:info -p "${project}" -e "${environment}" > /dev/null 2>&1; then
  error Environment "${environment}" on project "${project}" already exists. \
    Use the delete command to remove it and start over if necessary.
fi

# clone new environment from master (~5-10 min)
"${cli_path}" environment:branch -p "${project}" "${environment}"  master --force

msg Disabling cron ...
disable_cron "${project}" "${environment}"

msg Sending tar file ...
transfer_local_tar_to_remote "${local_tar_file}" "${project}" "${environment}"

msg Restoring files from tar ...
restore_files_from_tar "${local_tar_file}" "${project}" "${environment}"

msg Restoring DB from tar ...
restore_db_from_tar "${local_tar_file}" "${project}" "${environment}"

# extract tar file to tmp dir and make git repo to push to cloud
msg Extract tar locally and create git repo to forcefully push containing updated composer.* files
rm -rf "${tmp_git_dir}" # ensure tmp_git_dir doesn't exist from a previously aborted cmd
mkdir -p "${tmp_git_dir}"
tar -xf "${backups_dir}/${local_tar_file}" -C "${tmp_git_dir}" "${app_dir#'/'}"
cd "${tmp_git_dir}${app_dir}"
git init
git remote add cloud $("${cli_path}" project:info -p "${project}" git)
git checkout -b "${environment}"
git add .
git add -f auth.json
git commit -m "Creating from backup: ${local_tar_file}"
git push -f -u cloud "${environment}"

msg Restoring media ...
$ssh_cmd "
  rm -rf /app/pub/media/catalog/product/cache/

  # rename any files by md5 hash and cleanup dirs
  find /app/pub/media -type f -regextype posix-extended -not -regex '^/app/pub/media/[a-f0-9]{32}$' -exec md5sum {} \; | \
    perl -pe 's%^(.*?) +(.*)$%mv \2 /app/pub/media/\1%' | \
    bash
  find /app/pub/media -type d -empty -delete

  # create list of existing media
  find /app/pub/media -type f | perl -pe 's/.*\///' > ${local_media_files_md5s}

  # remove files that we already have
  grep -vf ${local_media_files_md5s} ${all_media_files_plus_md5_list_in_orig_env} > ${differential_list_of_media_files}

  # transfer missing media files
  perl -pe 's/ +.*//' ${differential_list_of_media_files} > ${transfer_list}
  rsync --files-from=${transfer_list} ${backup_server}:/app/pub/media/ /app/pub/media/ 2>/dev/null

  # sort & for each md5sum, cp each file then rm after last cp to prevent possible > 2x pub/media size
  sort ${all_media_files_plus_md5_list_in_orig_env} | \
    perl



 "

 msg Enabling cron ...
 enable_cron "${project}" "${environment}"