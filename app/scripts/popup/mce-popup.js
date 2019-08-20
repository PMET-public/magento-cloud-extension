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

  const curManifestVersion = chrome.runtime.getManifest().version
  $('#manifest-version').text('(cur ver: ' + curManifestVersion + ')')
  const curManifestVersionParts = curManifestVersion.split('.')
  // check current manifest vs remote manifest
  fetch('https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/app/manifest.json')
    .then(response => response.json())
    .then(json => {
      const remoteManifestParts = json.version.split('.')
      remoteIsNewer = false
      for (let i = 0; i < remoteManifestParts.length; i++) {
        if (parseInt(remoteManifestParts[i], 10) > parseInt(curManifestVersionParts[i], 10)) {
          remoteIsNewer = true
          break
        }
      }
      if (remoteIsNewer) {
        $('.extension-title').append('<div class="cli-cmd-container update-available">' +
        '<span class="mdi mdi-content-copy simple-copy"></span>' +
        '<div class="help-wrapper" data-descr="Click to copy. Then paste in terminal.">Update! <span  class="mdi mdi-help"></span></div>' +
        '<input class="cli-cmd" type="text" value="curl -sS https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/{{version}}/sh-scripts/lib.sh ' +
        'https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/{{version}}/sh-scripts/update-extension.sh | ' +
        'env ext_ver={{version}} tab_url={{tab_url}} bash" readonly></div>')
        // <a class="update-available" target="_blank" href="https://github.com/PMET-public/magento-cloud-extension/releases">Update! -&gt; </a>
      }
    })

})
