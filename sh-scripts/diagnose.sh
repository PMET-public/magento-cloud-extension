report=/tmp/report-$(date "+%m-%d-%H-%M").log

msg Diagnosing Magento applicatioon | tee -a $report
$ssh_cmd "
  cd ${app_dir}/var;
  test -f .maintenance.flag && \
    echo '.maintenance.flag found. Removing ...' && \
    rm .maintenance.flag
  test -f .deploy_is_failed && \
    echo '.deploy_is_failed found. Removing ...' && \
    rm .deploy_is_failed
  echo 'Tailing relevant end of install_upgrade.log:'
  cat ${app_dir}/var/log/install_upgrade.log | \
    perl -pe 's/\e\[\d+(?>(;\d+)*)m//g;' | \
    grep -v '^Module ' | \
    grep -v '^Running schema' | \
    perl -pe 's/^/\t/' | \
    tail
  echo 
" 2> /dev/null | tee -a $report

exit

msg Checking load on env ... | tee -a $report

read -r nproc loadavg1 loadavg5 < <($ssh_cmd 'echo $(nproc) $(awk "{print \$1, \$2}" /proc/loadavg)' 2> /dev/null)

load1=$(awk "BEGIN {printf \"%.f\", $loadavg1 * 100 / $nproc}")
load5=$(awk "BEGIN {printf \"%.f\", $loadavg5 * 100 / $nproc}")

[[ $load1 -gt 99 ]] && color="$red" || [[ $load1 -gt 89 ]] && color="$yellow" || color="${green}"
printf "The past 1 min load for this host: ${color}${load1}%%${no_color}\n" | tee -a $report
printf "The past 5 min load for this host: ${color}${load5}%%${no_color}\n" | tee -a $report
echo "Just a reminder: host =/= env. A env may be limited even if resources are available on its host."


# copy report to clipboard and strip color characters
cat $report | perl -pe 's/\e\[\d+(?>(;\d+)*)m//g;' | pbcopy
