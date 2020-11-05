# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

declare -a "projects=($($cli_path projects --format=tsv --no-header --columns=title,id | perl -pe 's/\t/ (/g;s/^/"/;s/\s+$/)"\n/'))"
if [[ ${#projects[@]} -lt 1 ]]; then
  error "No projects found. Is your Magento Cloud CLI installed and logged in?"
fi

PS3="
Choose which \"Project Title (project id)\" above to update: "
select project in "${projects[@]}"; do
  if [[ -z "$project" ]]; then
    echo "Invalid choice. Exiting ..." && exit
  fi
  project=$(echo $project | perl -pe 's/.*\(//;s/\).*//')
  break
done < /dev/tty

echo "

-----------------

"

declare -a "environments=($($cli_path environments -p $project --format=tsv --no-header --columns=title,id | perl -pe 's/\t/ (/g;s/^/"/;s/\s+$/)"\n/'))"
if [[ ${#environments[@]} -lt 1 ]]; then
  error "No environments found. Should not be possible."
fi

PS3="
Choose which \"Environment Name (environment id)\" above to update: "
select environment in "${environments[@]}"; do
  if [[ -z "$environment" ]]; then
    echo "Invalid choice. Exiting ..." && exit
  fi
  environment=$(echo $environment | perl -pe 's/.*\(//;s/\).*//')
  break
done < /dev/tty

echo "

-----------------

"

read -r -n 1 -p "Choose an option:
1) Use ssh to bypass url restrictions and access 1 of your envs at http://demo.the1umastory.com
2) Revert a previous url change and set your env back to its original url
" < "$read_input_src"
echo ""
case ${REPLY} in
1)
  if nc -d -z 127.0.0.1 80 2> /dev/null; then
    error "Another program is already using port 80. Please stop it before continuing. If you are unsure which program, try running: 
    sudo lsof -i4TCP:80 -sTCP:LISTEN -n -P"
  fi
  echo "You may be prompted for your local computer password to listen on port 80."
  sudo ssh -L 80:127.0.0.1:80 $($cli_path ssh -p $project -e $environment --pipe) '
    echo "Updating ..."
    php bin/magento setup:store-config:set --base-url=http://demo.the1umastory.com/
    php bin/magento setup:store-config:set --use-secure-admin=0
    echo "Flushing the cache ..."
    php bin/magento cache:flush > /dev/null
    printf "\033[1;33mREMEMBER to rerun this script and revert the change when done!!! (option #2)\033[0m\n"
    echo "Your env is now accessible at http://demo.the1umastory.com/ until you press Ctrl-c to quit."
    sleep 99999
  '
  ;;
2)
  ssh $($cli_path ssh -p $project -e $environment --pipe) '
    echo "Updating ..."
    url=$(echo $MAGENTO_CLOUD_ROUTES | base64 -d | perl -pe "s#.*?(http://.*?/).*#\1#")
    php bin/magento setup:store-config:set --base-url=${url}
    php bin/magento setup:store-config:set --use-secure-admin=1
    echo "Flushing the cache ..."
    php bin/magento cache:flush > /dev/null
    echo "Env reverted to ${url}"
    pkill sleep
  '
  ;;
*)
  echo "Invalid choice. Exiting ..." && exit
  ;;
esac
