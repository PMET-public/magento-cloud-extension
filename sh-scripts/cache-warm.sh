msg Warming cache ...

wget_url=$(echo "${url}" | perl -pe "s!^(https?://[^/]+).*!\1!")
wget_domain=$(echo "${wget_url}" | perl -pe "s!https?://!!")

tmp_file=/tmp/$(date '+delete-me-%Y-%m-%d-%H-%M-%S')]

# recursively get admin and store front
$ssh_cmd "wget -r -l 1 -O ${tmp_file} -H --domains=${wget_domain} ${wget_url}/admin
  wget -r -l 1 -O ${tmp_file} -H --domains=${wget_domain} ${wget_url}
  rm ${tmp_file}"
