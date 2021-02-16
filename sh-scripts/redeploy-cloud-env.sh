# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Redeploying env ..."


"$cli_path" environment:redeploy -p "$project" -e -$environment"