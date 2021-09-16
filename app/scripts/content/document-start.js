'use strict'
MCExt.loadSavedCSS()

function addPassToEnvLink(e) {
  // only add if domain matches and a user+pass hasn't already been added
  if (e.target && e.target.href && /demo.magentosite.cloud/.test(e.target.href) && ! /\/\/[^:]*:[^@]*@/.test(e.target.href)) {
    e.target.href = e.target.href.replace(/(https?:\/\/)(.*-)(.*)(\.demo\.magentosite\.cloud)/, '$1admin:$3@$2$3$4')
  }
}

if (MCExt.isCurrentTabCloudProjects()) {
  window.addEventListener('click', addPassToEnvLink)
  window.addEventListener('contextmenu', addPassToEnvLink)
  MCExt.loadCSS(MCExt.cloudUiCss)
} else if (MCExt.isCurrentTabCloudEnv()) {
  console.log('cloud env')
} else {
  console.log('not cloud')
}