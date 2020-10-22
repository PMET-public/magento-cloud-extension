# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

echo $(get_interactive_ssh_cmd "$project" "$environment") | bash
