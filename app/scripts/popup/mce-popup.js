$(function() {

  // attempt to provide a direct link to the environment in the cloud ui when on a specific storefront
  // need to match an environment subdomain to a corresponding actual env name in the project list
  // use the list from the version css for matching
  fetch('https://master-7rqtwti-zajhc7u663lak.demo.magentosite.cloud/media/cloud-ui.css')
  .then(response => response.text())
  .then(txt => {
    const subdomainMatches = tabUrl.match(/.*?:\/\/([^.]+)-[^-]*-([^-]*)\.demo\.magentosite\.cloud\/.*/)
    if (subdomainMatches) {
      debugger
      const environmentInSubdomain = subdomainMatches[1]
      const projectInSubdomain = subdomainMatches[2]
      const matchesFromCss = txt.match(new RegExp('"/projects/' + projectInSubdomain + '/environments/' +  environmentInSubdomain.replace(/-/g,'[_\.\-]') + '"', 'ig'))
      if (matchesFromCss && matchesFromCss.length === 1) {
        $('#cloud-ui-link')[0].href='https://demo.magento.cloud' + matchesFromCss[0].replace(/"/g,'')
      } else {
        $('#cloud-ui-link')[0].href='https://demo.magento.cloud/projects/' + projectInSubdomain + '/environments/master'
      }
    }
  })

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
  $('.current-domain').text(appliedDomain)
  if (/\.magento\.cloud/.test(tabBaseUrl)) {
    const environment = tabUrl.replace(/.*\//,'')
    $('.target-env').text(`Env id: ${environment}`)
  } else {
    $('.target-env').text(tabBaseUrl)
  }

  const curManifestVersion = chrome.runtime.getManifest().version
  $('#manifest-version').text('(ver: ' + curManifestVersion + ')')
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
        '<div class="help-wrapper" data-descr="Click to copy. Then paste in terminal.">Update! <span  class="mdi mdi-bell-ring"></span></div>' +
        '<input class="cli-cmd" type="text" value="curl -sS https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/{{version}}/sh-scripts/lib.sh ' +
        'https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/{{version}}/sh-scripts/update-extension.sh | ' +
        'env ext_ver={{version}} tab_url={{tab_url}} bash" readonly></div>')
        // <a class="update-available" target="_blank" href="https://github.com/PMET-public/magento-cloud-extension/releases">Update! -&gt; </a>
      }
    })

})
