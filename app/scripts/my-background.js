'use strict'

handleExtensionIcon()
chrome.browserAction.setBadgeBackgroundColor({color: '#ff6d00'})

chrome.runtime.onInstalled.addListener(function (details) {
  console.log('previousVersion', details.previousVersion)
});

chrome.browserAction.onClicked.addListener(function(tab) {
  // Run the following code when the popup is opened
  console.log('popup clicked at ' + new Date()/1)
  chrome.tabs.query({active: true, currentWindow: true}, function(tabs) {
    var tabUrl = tabs[0].url;
    tabDomain = tabUrl.substring(0,tabUrl.indexOf('/', 8))
    console.log('tab is on ' + tabDomain)
  });
})
