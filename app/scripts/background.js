'use strict'

chrome.browserAction.setBadgeBackgroundColor({color: '#ff6d00'})

chrome.runtime.onInstalled.addListener(function (details) {
  console.log('previousVersion', details.previousVersion)
});
