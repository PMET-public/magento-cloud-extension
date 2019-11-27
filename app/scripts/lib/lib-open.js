chrome.tabs.query({active: true, currentWindow: true}, function(tabs) {

function handleExtensionIcon() {
  chrome.storage.local.get(['isCssInjectorOn'], function (result) {
    const isOn = result['isCssInjectorOn']
    chrome.browserAction.setBadgeText({text: isOn ? 'on' : ''})
    chrome.browserAction.setIcon({
      path: {
        '16': '../images/cloud-' + (isOn ? '' : 'disabled-') + '16.png',
        '24': '../images/cloud-' + (isOn ? '' : 'disabled-') + '24.png',
        '32': '../images/cloud-' + (isOn ? '' : 'disabled-') + '32.png',
        '48': '../images/cloud-' + (isOn ? '' : 'disabled-') + '48.png'
      }
    })
  })
}

const tabUrl = tabs[0].url
const tabBaseUrl = tabUrl.substring(0,tabUrl.indexOf('/', 8))
const appliedDomain = tabBaseUrl.replace(/.*\/\//,'')
const curManifestVersion = chrome.runtime.getManifest().version

