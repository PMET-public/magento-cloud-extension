
wget_url=$(echo "${url}" | perl -pe "s!^(https?://[^/]+).*!\1!")
wget_domain=$(echo "${wget_url}" | perl -pe "s!https?://!!")

# recursively get admin and store front
wget -r -l 1 -O delete-me -H --domains="${wget_domain}" "${wget_url}/admin"
wget -r -l 1 -O delete-me -H --domains="${wget_domain}" "${wget_url}"
rm delete-me
