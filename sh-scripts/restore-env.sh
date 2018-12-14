msg Restoring env from backup ...

# prompt user for tar file and project to create new env on
backtitle="Restoring env from backup ..."

if is_cloud; then
  tar_file_pattern="${project}-${environment}"
else
  tar_file_pattern="${domain}"
fi

tar_files=($(find "${backups_dir}" -name "*-${tar_file_pattern}.tar" 2>/dev/null | sort -r | perl -pe 's!.*/!!' | cat -n))
if [[ ${#tar_files[@]} -lt 1 ]]; then
  error No files matching "*-${tar_file_pattern}" found in "${backups_dir}"
fi

selection=$(dialog --clear \
  --backtitle "${backtitle}" \
  --title "Your Backup(s)" \
  --menu "Choose a backup file to deploy to ${pattern}:" \
  $menu_height $menu_width $num_visible_choices "${tar_files[@]}" \
  2>&1 >/dev/tty)
clear

tar_file="${tar_files[$(( (${selection} - 1) * 2 + 1))]}"

restore_from_tar "${tar_file}" "${project}" "${environment}"
