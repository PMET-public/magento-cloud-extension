read -p "
Enter username of admin account to unlock or leave blank for 'admin':
" -r < /dev/tty
user="$REPLY"
if [[ -z "$user" ]]; then
  user=admin
fi

$ssh_cmd "php ${app_dir}/bin/magento admin:user:unlock ${user};"
