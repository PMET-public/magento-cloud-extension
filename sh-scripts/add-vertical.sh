# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

addGrocery(){
  msg "Adding Fresh Market website ..."
  msg "Attempting legacy install"
  
  $cmd_prefix "
    php $app_dir/bin/magento gxd:datainstall StoryStore_Grocery --load=website
  "
  msg "Attempting updated install"
  $cmd_prefix "
    php $app_dir/bin/magento gxd:datainstall MagentoEse_VerticalDataGrocery
  "
  msg "Fresh Market website available at ${base_url}fresh"
}

addAuto(){
  msg "Adding Carvelo Autoparts website..."

  $cmd_prefix "
    php $app_dir/bin/magento gxd:datainstall MagentoEse_VerticalDataAuto
    php $app_dir/bin/magento gxd:datainstall MagentoEse_VerticalDataAuto -r --files=msi_inventory.csv
  "
  msg "Carvelo Auto Parts website available at ${base_url}auto"
}

addHealthBeauty(){
  msg "Adding Anaïs Clément website ..."

  $cmd_prefix "
    php $app_dir/bin/magento gxd:datainstall MagentoEse_VerticalDataHealthBeauty
    php $app_dir/bin/magento gxd:datainstall MagentoEse_VerticalDataHealthBeauty -r --files=msi_inventory.csv
  "
  msg "Anaïs Clément website available at ${base_url}healthbeauty"
}

msg "Choose Website to add to project: $project environment: $environment\n*note availability if you are installing on older versions*"
msg "1) Fresh Market - Grocery (2.4.1+)\n2) Carvelo Auto Parts - Auto Parts (2.4.3+)\n3) Anaïs Clément - Health & Beauty (2.4.3-p1+)"


read -r -n 1 -p "Enter Number: " < "$input_src" 2> "$output_src"

case $REPLY in
  1)
    addGrocery
    ;;
  2)
    addAuto
    ;;
  3)
    addHealthBeauty
    ;;
  *)
    msg "\033[0;31mInvalid Selection"
    exit
    ;;
esac
