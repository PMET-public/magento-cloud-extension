'use strict';

chrome.runtime.onInstalled.addListener(function (details) {
  console.log('previousVersion', details.previousVersion);
});

// chrome.browserAction.setBadgeText({text: 'on'});

console.log('MC Demo Event Page for Browser Action');
