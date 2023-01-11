# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

read -r -p "
Enter username of admin account to unlock or leave blank for 'admin':
" < "$input_src" 2> "$output_src"
user="$REPLY"
if [[ -z "$user" ]]; then
  user=admin
fi

$cmd_prefix "php $app_dir/bin/magento admin:user:unlock $user"
