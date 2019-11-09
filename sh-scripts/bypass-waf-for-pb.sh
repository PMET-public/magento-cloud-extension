declare -a "projects=($(${cli_path} projects --format=tsv --no-header --columns=id,title | perl -pe 's/\t/\t\"/;s/\s+$/\"\n/'))"
if [[ ${#projects[@]} -lt 1 ]]; then
  error No projects found. Is your Magento Cloud CLI installed and logged in?
fi

project=$(dialog --clear \
  --backtitle "Project Selector" \
  --title "Your Project(s)" \
  --menu "Choose your project to update:" \
  $menu_height $menu_width $num_visible_choices "${projects[@]}" \
  2>&1 >/dev/tty)
clear

declare -a "environments=($(${cli_path} environments -p ${project} --format=tsv --no-header --columns=id,name | perl -pe 's/\t/\t\"/;s/\s+$/\"\n/'))"
if [[ ${#environments[@]} -lt 1 ]]; then
  error No environments found. Should not be possible.
fi

environment=$(dialog --clear \
  --backtitle "Environment Selection" \
  --title "Environment of Project ${project}" \
  --menu "Choose your environment to update:" \
  $menu_height $menu_width $num_visible_choices "${environments[@]}" \
  2>&1 >/dev/tty)
clear

read -p "Choose an option:
1) Use ssh to bypass url restrictions and access 1 of your envs at http://demo.the1umastory.com
2) Revert a previous url change and set your env back to its original url
" -n 1 -r < /dev/tty
echo ""
case ${REPLY} in
1)
  echo "You will now be prompted for your local computer password to listen on port 80."
  echo "If you have apache or another web server running on port 80, you must stop it first."
  sudo ssh -L 80:127.0.0.1:80 $(${cli_path} ssh -p ${project} -e ${environment} --pipe) '
    echo "Updating ..."
    php bin/magento setup:store-config:set --base-url=http://demo.the1umastory.com/
    php bin/magento setup:store-config:set --use-secure-admin=0
    echo "Flushing the cache ..."
    php bin/magento cache:flush > /dev/null
    echo "Your env is now accessible at http://demo.the1umastory.com/ until you press Ctrl-c to quit"
    sleep 9999999
  '
  ;;
2)
  ssh $(${cli_path} ssh -p ${project} -e ${environment} --pipe) '
    echo "Updating ..."
    url=$(echo $MAGENTO_CLOUD_ROUTES | base64 -d | perl -pe "s#.*?(http://.*?/).*#\1#")
    php bin/magento setup:store-config:set --base-url=${url}
    php bin/magento setup:store-config:set --use-secure-admin=1
    echo "Flushing the cache ..."
    php bin/magento cache:flush > /dev/null
    echo "Env reverted to ${url}"
  '
  ;;
*)
  echo "Invalid choice. Exiting ..."
  exit
  ;;
esac
