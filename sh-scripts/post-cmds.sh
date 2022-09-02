# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

# post cmd script for cleanup action (e.g. revert php version)

# no longer needed 
# if $php_changed; then
#   msg "Restoring php to v$php_version..."
#   brew unlink php
#   brew link php@$php_version
# fi
