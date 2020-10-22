msg "Creating admin user. You will be prompted for a username, password, and email address."

read -r -p "
Enter username of new admin account:
"
user="$REPLY"
if [[ -z "$user" ]]; then
  error "Username can not be empty."
fi

read -r -p "
Enter password of new admin account: (7+ chars; must include letters and numbers)
"
password="$REPLY"
if [[ -z "$password" ]]; then
  error "Username can not be empty."
fi

read -r -p "
Enter email of new admin account: (does not need to be real)
"
email="$REPLY"
if [[ -z "$email" ]]; then
  error "Username can not be empty."
fi

$cmd_prefix "php $app_dir/bin/magento admin:user:create \
  --admin-user=${user} \
  --admin-password=${password} \
  --admin-email=${email} \
  --admin-firstname=Admin \
  --admin-lastname=Username"
