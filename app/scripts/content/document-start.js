'use strict'
MCExt.loadSavedCSS()
if (MCExt.isCurrentTabCloudProjects()) {
  (async function () {
    console.log('cloud project')
    let projects = await MCExt.parseCloudEnvVersions()
    console.log(projects)
  })()
} else if (MCExt.isCurrentTabCloudEnv()) {
  console.log('cloud env')
  MCExt.parseCloudEnvVersions()
} else {
  console.log('not cloud')
}