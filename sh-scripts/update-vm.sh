msg Diagnosing, attempting to repair, and reporting ...

# fetch the mcm version
# and turn off debugging (by default, debugging is on)
$ssh_cmd "curl -s $ext_raw_git_url/sh_scripts/remote/updates-to-run-directly-on-vm.sh | env debug=${debug:=0} bash" |
  tee /dev/tty |
  # copy report to clipboard and strip color characters
  perl -pe 's/\e\[\d+(?>(;\d+)*)m//g;' | pbcopy


