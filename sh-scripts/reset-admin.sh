printf "\nCreating/resetting admin user ...\n"

$ssh_cmd "php ${home_dir}/bin/magento admin:user:unlock ${user};
  php ${home_dir}/bin/magento admin:user:create --admin-user=${user} --admin-password=${password} --admin-email=${email} --admin-firstname=Admin --admin-lastname=Username"
