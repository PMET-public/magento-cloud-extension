read -p "
Enter username of admin account to unlock or leave blank for 'admin':
" -r < /dev/tty
user="$REPLY"
if [[ -z "$user" ]]; then
  user=admin
fi

$cmd_prefix "php ${app_dir}/bin/magento admin:user:unlock ${user};"
