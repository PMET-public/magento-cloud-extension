# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Downloading MDM-lite ..."

rm -rf MDM-lite.app
cd "$HOME/Downloads"
curl -sL -o mdm.zip https://github.com/PMET-public/mdm/releases/download/1.0.12/MDM-lite.app.zip
unzip mdm
rm mdm.zip
chmod +x MDM-lite.app/Contents/MacOS/MDM-lite
# https://apple.stackexchange.com/questions/202169/how-can-i-open-an-app-from-an-unidentified-developer-without-using-the-gui
xattr -dr com.apple.quarantine "MDM-lite.app"
open MDM-lite.app