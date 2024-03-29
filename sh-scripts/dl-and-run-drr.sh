# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Diagnosing, attempting to repair, and reporting ..."

# fetch the diagnose, repair, report script from the master branch
# and turn off debugging (by default, debugging is on)
$cmd_prefix "curl -s https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/sh-scripts/diagnose-repair-report.sh |
  env debug=${debug:=0} bash" |
  tee "$output_src" |
  # copy report to clipboard and strip color characters
  perl -pe 's/\e\[\d+(?>(;\d+)*)m//g;' | pbcopy

test ! -z "$(pbpaste)" &&
  warning "Report copied to clipboard. If you have questions or need assistance, please paste it in the \#m2-demo-support slack channel." ||
  error "Report did not run successfully. Check internet connection."


