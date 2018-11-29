printf "\nCreating new cloud env from backup ...\n"

# prompt user for tar file and project to create new env on
menu_height=20
menu_width=70
num_visible_choices=10
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

read -r tar_file_index project_id <<<"${selections}"
tar_file="${tar_files[$(( (${tar_file_index} - 1) * 2 + 1))]}"
tmp_tar_dir=$(echo "${tar_file}" | sed 's/^/\/tmp\//;s/.tar$//')
git_branch="${tar_file%.tar}"

# extract tar file to tmp dir and make git repo
mkdir -p "${tmp_tar_dir}"
tar -xf "${backups_dir}/${tar_file}" -C "${tmp_tar_dir}"
cd "${tmp_tar_dir}"
git init
git remote add cloud $("${cli_path}" project:info -p "${project_id}" git)
git checkout -b "${git_branch}"
git add .
git commit -m "Creating from backup: ${tar_file}"
git push --set-upstream cloud "${git_branch}"


# push to cloud & wait for installation to complete

# send tar file

# extract files

# replace hostname

# restore db
