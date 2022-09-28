# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

warning "Press control-c to stop or simply close terminal."
#  $cmd_prefix "stdbuf -oL tail -f /var/log/php.access.log $app_dir/var/log/system.log $app_dir/var/log/exception.log | \
#    stdbuf -oL perl -pe 's!$app_dir/var/log/system.log!${green}\$&${no_color}!; s!$app_dir/var/log/exception.log!${red}\$&${no_color}!;'"

is_cloud &&
  access_log=/var/log/access.log ||
  access_log=/var/log/nginx/access.log

# ignore simple GET requests from the access log that return 200
$cmd_prefix "tail -n 3 -f $access_log $app_dir/var/log/system.log $app_dir/var/log/exception.log | stdbuf -oL grep -E -v 'GET .* 200 '"
