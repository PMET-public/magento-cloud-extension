'use strict'
MCExt.loadSavedCSS()
if (MCExt.isCurrentTabCloudProjects()) {
  function addPassToEnvLink(e) { 
    if (e.target && e.target.href && /demo.magentosite.cloud/.test(e.target.href)) {
      e.target.href = e.target.href.replace(/(https?:\/\/)(.*-)(.*)(\.demo\.magentosite\.cloud)/, '$1admin:$3@$2$3$4')
    }
  }
  window.addEventListener('click', addPassToEnvLink)
  window.addEventListener('contextmenu', addPassToEnvLink)
  MCExt.loadCSS(MCExt.cloudUiCss)
} else if (MCExt.isCurrentTabCloudEnv()) {
  console.log('cloud env')
} else {
  console.log('not cloud')
}