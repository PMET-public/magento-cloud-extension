printf "\nWatching logs ...\n"

#  $ssh_cmd "stdbuf -oL tail -f /var/log/php.access.log ${app_dir}/var/log/system.log ${app_dir}/var/log/exception.log | \
#    stdbuf -oL perl -pe 's!${app_dir}/var/log/system.log!${green}\$&${no_color}!; s!${app_dir}/var/log/exception.log!${red}\$&${no_color}!;'"

$ssh_cmd "stdbuf -oL tail -f /var/log/php.access.log ${app_dir}/var/log/system.log ${app_dir}/var/log/exception.log"
