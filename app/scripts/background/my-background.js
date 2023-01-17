'use strict'

handleExtensionIcon()
// test if function exists b/c chrome reports error in chrome://extensions view under some circumstances
if (chrome.action.setBadgeBackgroundColor) {
  chrome.action.setBadgeBackgroundColor({color: '#ff6d00'})
}
