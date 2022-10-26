# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Creating admin user. You will be prompted for a username, password, and email address."

read -r -p "
Enter username of new admin account:
" < "$read_input_src" 2>/dev/tty
user="$REPLY"
if [[ -z "$user" ]]; then
  error "Username can not be empty."
fi

read -r -p "
Enter password of new admin account: (7+ chars; must include letters and numbers)
" < "$read_input_src" 2>/dev/tty
password="$REPLY"
if [[ -z "$password" ]]; then
  error "Password can not be empty."
fi

read -r -p "
Enter email of new admin account: (does not need to be real)
" < "$read_input_src" 2>/dev/tty
email="$REPLY"
if [[ -z "$email" ]]; then
  error "Email can not be empty."
fi

$cmd_prefix "php $app_dir/bin/magento admin:user:create \
  --admin-user=${user} \
  --admin-password=${password} \
  --admin-email=${email} \
  --admin-firstname=Admin \
  --admin-lastname=Username"
