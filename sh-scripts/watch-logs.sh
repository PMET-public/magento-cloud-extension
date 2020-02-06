warning Press control-c to stop or simply close terminal.
#  $cmd_prefix "stdbuf -oL tail -f /var/log/php.access.log ${app_dir}/var/log/system.log ${app_dir}/var/log/exception.log | \
#    stdbuf -oL perl -pe 's!${app_dir}/var/log/system.log!${green}\$&${no_color}!; s!${app_dir}/var/log/exception.log!${red}\$&${no_color}!;'"

is_cloud &&
  access_log=/var/log/access.log ||
  access_log=/var/log/nginx/access.log

$cmd_prefix "stdbuf -oL tail -n 3 -f $access_log ${app_dir}/var/log/system.log ${app_dir}/var/log/exception.log"
