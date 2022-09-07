- [Installation (how to update below)](#installation-how-to-update-below)
- [Automatic Updates](#automatic-updates)
- [How to Manually Update - 1 min video (for older versions)](#how-to-manually-update---1-min-video-for-older-versions)
- [Recommended IDE & Extensions](#recommended-ide--extensions)
- [Developer Setup](#developer-setup)
- [Troubleshooting](#troubleshooting)

## Installation (how to update below)

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

## Automatic Updates
1. Quick the update link in the extension
2. Paste the cmd copied to your clipboard in the terminal
3. If you haven't previously, you may get a dialog to grant the terminal permission to access your Downloads folder in recent versions of OSX.

## How to Manually Update - 1 min video (for older versions)
[![Quick Install Video](http://img.youtube.com/vi/JDBgG4Hs_No/0.jpg)](https://www.youtube.com/watch?v=JDBgG4Hs_No "Quick Update Video")

1. Quick the update link in the extension
2. Download & open zip file
3. Chrome settings (⋮) → More Tools → Extensions
4. Remove old extension
5. Turn on "Developer Mode" (if not already on)
6. Click "Load Unpacked"
7. Select unzipped folder at Downloads > mcm-chrome-ext

Done

## Recommended IDE & Extensions

IDE: [VSC](https://code.visualstudio.com/download)

IDE Extensions:
1. [Bash Debug](https://github.com/rogalmic/vscode-bash-debug)
1. [BASH IDE](https://github.com/bash-lsp/bash-language-server)
1. [Bats](https://github.com/jetmartin/bats)
1. [shellcheck](https://github.com/timonwong/vscode-shellcheck)

The included `.vscode/launch.json` has some useful debug scenarios pre-configured that you can use to step through.

## Developer Setup

Currently tested & built on node 10.x

1. clone, install dependencies, and build
``` bash
git clone --recurse-submodules git@github.com:PMET-public/magento-cloud-extension.git
cd magento-cloud-extension
fnm use
npm i
./node_modules/gulp/bin/gulp.js -f gulpfile.mjs dev-build
```
2. install extension as above

See the `zip` gulp task for publishing.

## Troubleshooting

Besides the IDE tools listed above, you can set an environmental var `debug=1` that invokes the `set +x` option which enables additional output.

Example: (Note the `debug=1` directly preceding `bash` at the end.)

```bash
# example c&p cmd
curl -sS https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/0.0.30/sh-scripts/{lib.sh,reindex.sh} | env ext_ver=0.0.30 tab_url=https://khb-del-me-vnrx66q-a6terwtbk67os.demo.magentosite.cloud debug=1 bash

# example output
+ set -e
+ red='\033[0;31m'
+ green='\033[0;32m'
+ yellow='\033[1;33m'
+ no_color='\033[0m'
+ read_input_src=/dev/tty
+ [[ -n '' ]]
+ cli_required_version=1.36.4
+ [[ /Users/kbentrup == \/\a\p\p ]]
+ cli_path=/Users/kbentrup/.magento-cloud/bin/magento-cloud
++ /Users/kbentrup/.magento-cloud/bin/magento-cloud --version
++ perl -pe 's/.*?([\d\.]+)/\1/'
+ cli_actual_version=1.36.4
+ [[ 1.36.4 != \1\.\3\6\.\4 ]]
....
```