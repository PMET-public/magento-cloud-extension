
$SSH_CMD "php bin/magento admin:user:unlock ${user};
  php bin/magento admin:user:create --admin-user=${user} --admin-password=${password} --admin-email=${email} --admin-firstname=Admin --admin-lastname=Username"
