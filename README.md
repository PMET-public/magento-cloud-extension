

## Installation


[![Quick Install Video](http://img.youtube.com/vi/x3KF-Y_8R00/0.jpg)](https://www.youtube.com/watch?v=x3KF-Y_8R00 "Quick Install Video")

Magento Cloud Chrome Extension

https://github.com/PMET-public/magento-cloud-extension/releases

**Details**

To install the Magento Cloud Extension:
1. Download the release zip file and unzip
2. Chrome settings (⋮) → More Tools → Extensions
3. Turn on "Developer Mode"
4. Click "Load Unpacked" 
5. Select unzipped folder from step #1.

Incognito Access:

6. Click "Details" for the extension
7. Turn on "Allow in incognito"

To install the Magento Cloud CLI & setup ssh keys:
1. Clicks the "Commands" tab in the extension
2. Click "Prerequisites"
3. Copy and paste those commands in your terminal
4. Note that you may be asked to login once `~/.magento-cloud/bin/magento-cloud login`

Done


** Details for Developers **

1. git clone
2. git submodule update --init --recursive
3. npm install
4. cd app; bower install
5. cd ..; gulp dev-build

