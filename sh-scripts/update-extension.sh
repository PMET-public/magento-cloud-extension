msg Downloading and extracting extension ...

rm ~/Downloads/mcm-chrome-ext.zip || :

if [[ -z "${master_ver}" ]]; then
  master_ver=$(curl -sS https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/app/manifest.json | perl -ne 's/^\s*"version"\s*:\s*"(.*)".*/\1/ and print')
fi

curl -L -o ~/Downloads/mcm-chrome-ext.zip --create-dirs https://github.com/PMET-public/magento-cloud-extension/releases/download/${master_ver}/mcm-chrome-ext.zip

find ~/Downloads/mcm-chrome-ext -type f ! -name 'manifest.json' -delete

unzip -o -d ~/Downloads/mcm-chrome-ext ~/Downloads/mcm-chrome-ext.zip
