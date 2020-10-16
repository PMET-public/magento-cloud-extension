msg "Downloading and running update script ..."

# and turn off debugging (by default, debugging is on)
$cmd_prefix "curl -s $ext_raw_git_url/sh-scripts/remote/updates-to-run-directly-on-vm.sh | env debug=${debug:=0} bash"
