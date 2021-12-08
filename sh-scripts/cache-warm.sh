msg "Warming cache ..."

wget_url=$(echo "${tab_url}" | perl -pe "s!^(https?://[^/]+).*!\1!")
wget_domain=$(echo "${wget_url}" | perl -pe "s!https?://!!")
tmp_file="/tmp/$(date '+delete-me-%Y-%m-%d-%H-%M-%S')"

# recursively get admin and store front
$cmd_prefix "
  # hide 403 error when accessing /admin (expected; we're just warming cache)
  wget -nv -O ${tmp_file} -H --domains=${wget_domain} ${wget_url}/admin 2> /dev/null 
  wget -nv -r -X static,media -l 1 -O ${tmp_file} -H --domains=${wget_domain} ${wget_url}
  rm ${tmp_file}
"
