
read -r nproc loadavg1 loadavg5 < <($SSH_CMD 'echo $(nproc) $(awk "{print \$1, \$2}" /proc/loadavg)' 2> /dev/null)

load1=$(awk "BEGIN {printf \"%.f\", $loadavg1 * 100 / $nproc}")
load5=$(awk "BEGIN {printf \"%.f\", $loadavg5 * 100 / $nproc}")

[[ $load1 -gt 99 ]] && color="$red" || [[ $load1 -gt 89 ]] && color="$yellow" || color="$green"
printf "The past 1 min load for this host: $color$load1%%$no_color\n"
printf "The past 5 min load for this host: $color$load5%%$no_color\n"
echo "Just a reminder: host =/= env. A env may be limited even if resources are available on its host."
