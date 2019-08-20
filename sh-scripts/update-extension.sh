msg Downloading and extracting extension ...

rm ~/Downloads/mcm-chrome-ext/mcm-chrome-ext.zip || :

curl -L -o ~/Downloads/mcm-chrome-ext/mcm-chrome-ext.zip --create-dirs https://github.com/PMET-public/magento-cloud-extension/releases/download/${ext_ver}/mcm-chrome-ext-${ext_ver}.zip

find ~/Downloads/mcm-chrome-ext -type f ! -name 'manifest.json' -a ! -name 'mcm-chrome-ext.zip' -delete

unzip -o -d ~/Downloads/mcm-chrome-ext ~/Downloads/mcm-chrome-ext/mcm-chrome-ext.zip
