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
    checkExtUpdateAvailable().then(available => {
      if (available) {
        chrome.browserAction.setBadgeText({text: 'up ⇪'})
      }
    })
  })
}

async function checkExtUpdateAvailable() {
  const response = await fetch('https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/app/manifest.json')
  const json = await response.json()
  const remoteManifestParts = json.version.split('.')
  var remoteIsNewer = false
  for (let i = 0; i < remoteManifestParts.length; i++) {
    if (parseInt(remoteManifestParts[i], 10) > parseInt(curManifestVersion.split('.')[i], 10)) {
      remoteIsNewer = true;
      break;
    }
  }
  // return remoteIsNewer || true
  return remoteIsNewer
}

// replace method removes any password
const tabUrl = tabs[0].url.replace(/:\/\/[^/]*@/,'://')
const tabBaseUrl = tabUrl.substring(0,tabUrl.indexOf('/', 8))
const appliedDomain = tabBaseUrl.replace(/.*\/\//,'')
const curManifestVersion = chrome.runtime.getManifest().version
const isCloud = /\.magento(site)?\.cloud/.test(tabBaseUrl)
const isVM = !isCloud
