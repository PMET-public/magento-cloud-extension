msg Toggling system emails ...

$cmd_prefix "
  val=\$(mysql ${db_opts} -sNe \"select value from core_config_data where path = 'system/smtp/disable';\")
  if [[ \"\${val}\" =~ 0 ]]; then
    toggled_val=1
    echo Turning system emails off
  else
    toggled_val=0
    echo Turning system emails on
  fi
  mysql ${db_opts} -e \"insert into core_config_data (scope, scope_id, path, value) values ('default', 0, 'system/smtp/disable', \${toggled_val}) on duplicate key update path='system/smtp/disable', value=\${toggled_val};\"
  php bin/magento cache:flush config
"
