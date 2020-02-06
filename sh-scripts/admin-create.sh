msg Creating admin user. You will be prompted for a username, password, and email address.

read -p "
Enter username of new admin account:
" -r < /dev/tty
user="$REPLY"
if [[ -z "$user" ]]; then
  error Username can not be empty.
fi

read -p "
Enter password of new admin account: (7+ chars; must include letters and numbers)
" -r < /dev/tty
password="$REPLY"
if [[ -z "$password" ]]; then
  error Username can not be empty.
fi

read -p "
Enter email of new admin account: (does not need to be real)
" -r < /dev/tty
email="$REPLY"
if [[ -z "$email" ]]; then
  error Username can not be empty.
fi

$cmd_prefix "php ${app_dir}/bin/magento admin:user:create \
  --admin-user=${user} \
  --admin-password=${password} \
  --admin-email=${email} \
  --admin-firstname=Admin \
  --admin-lastname=Username"
