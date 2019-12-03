curl -s --trace-ascii - -u admin:${project} http://google.com | perl -ne '/Authorization:/ and s/.*? // and print'
