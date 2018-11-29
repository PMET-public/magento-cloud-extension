printf "\nCopy imgs to an env ...\n"

# prompt user for tar file and project to create new env on
backtitle="Creating new cloud env from backup ..."

img_dirs=($(find "${HOME}/Downloads" -name "imgs-from-*" -type d 2>/dev/null | sort | perl -pe 's!.*/!!' | cat -n))
if [[ ${#img_dirs[@]} -lt 1 ]]; then
  error No image dirs from the store scraper found in "${HOME}/Downloads"
fi

selections=$(dialog --clear \
  --backtitle "${backtitle}" \
  --title "Your Image Dir(s) From Store Scraper" \
  --menu "Choose a dir to copy:" \
  $menu_height $menu_width $num_visible_choices "${img_dirs[@]}" \
  2>&1 >/dev/tty)
clear

