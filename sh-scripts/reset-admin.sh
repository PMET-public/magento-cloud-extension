printf "\nCreating/resetting admin user ...\n"

$ssh_cmd "php ${app_dir}/bin/magento admin:user:unlock ${user};
  php ${app_dir}/bin/magento admin:user:create --admin-user=${user} --admin-password=${password} --admin-email=${email} --admin-firstname=Admin --admin-lastname=Username"
