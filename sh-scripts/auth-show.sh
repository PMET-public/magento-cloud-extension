# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

curl -s --trace-ascii - -u admin:"$project" http://google.com | perl -ne '/Authorization:/ and s/.*? // and print'
