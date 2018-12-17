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

restore_db_from_tar "${local_tar_file}" "${project}" "${environment}"
restore_files_from_tar "${local_tar_file}" "${project}" "${environment}"

# extract tar file to tmp dir and make git repo to push to cloud
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
#"${cli_path}" environment:activate -p "${project}" -e "${environment}"


