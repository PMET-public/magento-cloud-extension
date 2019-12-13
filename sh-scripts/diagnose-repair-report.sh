msg Diagnosing, attempting to repair, and reporting ...

# fetch the mcm version of the diagnose, repair, report script
# and turn off debugging (by default, debugging is on)
$ssh_cmd "curl -s https://raw.githubusercontent.com/PMET-public/magento-cloud-manager/diagnose-repair-report/cli/bin/env-scripts/diagnose-repair-report.sh | 
  env debug=${debug:=0} bash" |
  tee /dev/tty |
  # copy report to clipboard and strip color characters
  perl -pe 's/\e\[\d+(?>(;\d+)*)m//g;' | pbcopy

warning Report copied to clipboard. If you have questions or need assistance, please paste it in the \#m2-demo-support slack channel.
