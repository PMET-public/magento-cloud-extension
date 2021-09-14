'use strict'

handleExtensionIcon()
// test if function exists b/c chrome reports error in chrome://extensions view under some circumstances
if (chrome.browserAction.setBadgeBackgroundColor) {
  chrome.browserAction.setBadgeBackgroundColor({color: '#ff6d00'})
}
