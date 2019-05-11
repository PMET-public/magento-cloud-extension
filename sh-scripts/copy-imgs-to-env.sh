msg Copy imgs to an env ...

# prompt user for tar file and project to create new env on
backtitle="Copy images to an env ..."

img_dirs=($(find "${HOME}/Downloads" -name "imgs-from-*" -type d 2> /dev/null | sort | perl -pe 's!.*/!!' | cat -n))
if [[ ${#img_dirs[@]} -lt 1 ]]; then
  error No image dirs from the store scraper found in "${HOME}/Downloads"
fi

selection=$(dialog --clear \
  --backtitle "${backtitle}" \
  --title "Your Image Dir(s) From Store Scraper" \
  --menu "Choose a dir to copy:" \
  $menu_height $menu_width $num_visible_choices "${img_dirs[@]}" \
  2>&1 >/dev/tty)
clear
img_dir="${img_dirs[$(( (${selection} - 1) * 2 + 1))]}"

scp -r "${HOME}/Downloads/${img_dir}/" $(get_ssh_url):${app_dir}/pub/media/import/products
