'use strict'
MCExt.loadSavedCSS()
if (MCExt.isCurrentTabCloudProjects()) {
  MCExt.loadCSS(MCExt.cloudUiCss)
} else if (MCExt.isCurrentTabCloudEnv()) {
  console.log('cloud env')
} else {
  console.log('not cloud')
}