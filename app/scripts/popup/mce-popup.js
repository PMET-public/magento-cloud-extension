$('.current-domain').text(appliedDomain)
$('#manifest-version').text('(ver: ' + curManifestVersion + ')')
$('#download_button').after(`<span class="image-copy">${cmdsToHtml(commands.filter(cmd => cmd.tags.includes('image-copy')))}</span>`)
if (/\.magento\.cloud/.test(tabBaseUrl)) {
  $('.target-env').text(`Env id: ${tabUrl.replace(/.*\//,'')}`)
} else {
  $('.target-env').text(tabBaseUrl)
  // append cur domain name to link
  $('#bw-link')[0].href = `https://builtwith.com/${tabBaseUrl.replace(/https?:\/\//,'').replace(/\/.*/,'')}`
}
$('#prereqs-cmds').append(cmdsToHtml(commands.filter(cmd => cmd.tags.includes('prerequisite'))))
$('#prereqs-accordion').accordion({
  active: 1,
  collapsible: true,
  heightStyle: "content"
})

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


// check current manifest vs remote manifest
fetch('https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/app/manifest.json')
  .then(response => response.json())
  .then(json => {
    const remoteManifestParts = json.version.split('.')
    var remoteIsNewer = false
    for (let i = 0; i < remoteManifestParts.length; i++) {
      if (parseInt(remoteManifestParts[i], 10) > parseInt(curManifestVersion.split('.')[i], 10)) {
        remoteIsNewer = true
        break
      }
    }
    if (remoteIsNewer||true) {
      $('.extension-title').append(`<span class="update-available">${cmdsToHtml(commands.filter(cmd => cmd.tags.includes('self-update')))}</span>`)
    }
  })
