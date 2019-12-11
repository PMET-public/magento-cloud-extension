msg Unlocking admin user ...

read -p "Enter username of admin account or leave blank for 'admin':
" -n 1 -r < /dev/tty

if [[ -z "${REPLY}" ]]; then
  user=admin
fi

$ssh_cmd "php ${app_dir}/bin/magento admin:user:unlock ${user};"
