$(function() {
  $('#tabs').tabs({
    activate: function (event, ui ) {
      // when a tab is clicked, store it as the current active one
      $('.ui-tabs-tab').each(function (i) { 
        if (this === ui.newTab[0]) { 
          chrome.storage.local.set({activeTab: i})
        }
      })
    }         
  })
  // after tabs created, get the last active tab and restore it
  chrome.storage.local.get(['activeTab'], function (result) {
    const activeTab = result['activeTab'] || 0
    if ($('.ui-tabs-tab a').length) {
      $('.ui-tabs-tab a').get(activeTab).click()
    }
  })
  $('.applied-domain').text(appliedDomain)

  // check current manifest vs remote manifest
  fetch('https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/app/manifest.json')
    .then(response => response.json())
    .then(json => {
      const remoteManifestParts = json.version.split('.')
      const curManifestParts = chrome.runtime.getManifest().version.split('.')
      remoteIsNewer = false
      for (let i = 0; i < remoteManifestParts.length; i++) {
        if (parseInt(remoteManifestParts[i], 10) > parseInt(curManifestParts[i], 10)) {
          remoteIsNewer = true
          break
        }
      }
      if (remoteIsNewer) {
        $('.extension-title').append('<a class="update-available" target="_blank" href="https://github.com/PMET-public/magento-cloud-extension/releases">update available!</a>')
      }
    })

})
