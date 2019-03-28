msg Toggling system emails ...

$ssh_cmd "
  val=$(mysql ${db_opts} -e 'select value from core_config_data where path = \"system/smtp/disable\";')
  if [[ $val =~ 0 ]]; then
    toggled_val=1
    echo Turning system emails pff
  else
    toggled_val=0
    echo Turning system emails on
  fi
  mysql ${db_opts} -e 'insert into core_config_data (scope, scope_id, path, value) values (\"default\", 0, \"system/smtp/disable\", ${toggle_val}) on duplicate key update path=\"system/smtp/disable\", value=${toggle_val};'
  php bin/magento cache:flush config
"
