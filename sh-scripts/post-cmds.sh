# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars


if $php_changed; then
  msg "Restoring php to v$php_version..."
  brew unlink php
  brew link php@$php_version
fi
