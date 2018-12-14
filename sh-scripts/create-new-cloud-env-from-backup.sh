msg Creating new cloud env from backup ...

# prompt user for tar file and project to create new env on
backtitle="Creating new cloud env from backup ..."

tar_files=($(find "${backups_dir}" -name "*.tar" 2>/dev/null | sort -r | perl -pe 's!.*/!!' | cat -n))
if [[ ${#tar_files[@]} -lt 1 ]]; then
  error No backups found in "${backups_dir}"
fi

# must use "declare -a" b/c some array items are quoted strings with spaces
declare -a "projects=($(${cli_path} projects --format=tsv | perl -pe 's/https:.*//' | sed '1d'))"
if [[ ${#projects[@]} -lt 1 ]]; then
  error No projects found. Is your Magento Cloud CLI installed and logged in?
fi

selections=$(dialog --clear \
  --backtitle "${backtitle}" \
  --title "Your Backup(s)" \
  --menu "Choose a backup file to deploy:" \
  $menu_height $menu_width $num_visible_choices "${tar_files[@]}" \
  --and-widget \
  --clear \
  --backtitle "${backtitle}" \
  --title "Your Project(s)" \
  --menu "Choose a project for the new env:" \
  $menu_height $menu_width $num_visible_choices "${projects[@]}" \
  2>&1 >/dev/tty)
clear

read -r tar_file_choice project <<<"${selections}"
if [[ "${tar_file_choice}" -lt 1 ]]; then
  exit # must have canceled the 1st menu (not sure why dialog cmd does not abort on its own in this scenario)
fi

tar_file="${tar_files[$(( (${tar_file_choice} - 1) * 2 + 1))]}" # account for menu numbering vs array with labels numbering
tmp_git_dir=$(echo "${tar_file}" | sed 's/^/\/tmp\//;s/.tar$//')
environment="${tar_file%.tar}"

# if env already exists in project, then exit with error
if ${cli_path} environment:info -p "${project}" -e "${environment}" > /dev/null 2>&1; then
  error Environment "${environment}" on project "${project}" already exists. \
    Use the delete command to remove it and start over if necessary.
fi

# extract tar file to tmp dir and make git repo to push to cloud
rm -rf "${tmp_git_dir}" # ensure tmp_git_dir doesn't exist from a previously aborted cmd
mkdir -p "${tmp_git_dir}"
tar -xf "${backups_dir}/${tar_file}" -C "${tmp_git_dir}"
cd "${tmp_git_dir}"
git init
git remote add cloud $("${cli_path}" project:info -p "${project}" git)
git checkout -b "${environment}"
git add .
git commit -m "Creating from backup: ${tar_file}"
git push --set-upstream cloud "${environment}"
"${cli_path}" environment:activate -p "${project}" -e "${environment}"

restore_from_tar "${tar_file}" "${project}" "${environment}"
