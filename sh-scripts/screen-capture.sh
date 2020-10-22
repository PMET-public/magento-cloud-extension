# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Select a window to capture to the clipboard ..."

screencapture -i -c -o -W

warning "Copied to clipboard! Now paste \( command ⌘ + v \) into slack or any other application."
