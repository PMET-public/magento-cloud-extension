# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Click the record button to select the area of the screen to record. "
warning "When finished, look for the stop button in the top menu bar. The save and upload in Slack or another app."

osascript -e 'tell application "QuickTime Player" 
    activate
    new screen recording
end tell'
