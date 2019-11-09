msg Bypass the web application firewall, to enable page builder

declare -a "projects=($(${cli_path} projects --format=tsv --no-header --columns=id,title | perl -pe 's/\t/\t\"/;s/\s+$/\"\n/'))"
if [[ ${#projects[@]} -lt 1 ]]; then
  error No projects found. Is your Magento Cloud CLI installed and logged in?
fi