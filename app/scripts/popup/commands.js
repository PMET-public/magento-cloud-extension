const rawGitUrl = 'https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/',
  rawGitPrefix = `${rawGitUrl}${curManifestVersion}/sh-scripts/`,
  // if url is part of magento.cloud (not magentosite.cloud or VM), use full url else just base url
  url = /magento\.cloud/.test(tabBaseUrl) ? tabUrl : tabBaseUrl

function copyToClipboard(el) {
  const copyClass = 'copied-to-clipboard-alert',
    jInput = $(el)
    .focus()
    .select()
  document.execCommand('copy')
  jInput[0].blur()
  $('#copy-overlay').css('display', 'flex')
  setTimeout(() => window.close(), 2000)
}

function matchCmd(cmd, key) {
  const re = new RegExp(key.trim(),'i')
  if (key.trim() === '' || re.test(cmd.text) || re.test(cmd.help) || re.test(cmd.cmdType) || re.test(cmd.additionalSearchTerms)) {
    return true
  }
  return false
}

function cmdsToHtml(cmds) {
  let html = ''
  cmds.forEach(cmd => html += `
    <div class="cli-cmd-container">
    ${cmd.text}
    ${cmd.help ? `<span class="cmd-help">${cmd.help}</span>` : ''}
    <input class="cli-cmd" type="text" readonly
      value="curl -sS ${rawGitPrefix}{${cmd.scriptsInValue.join(',')}} | env ext_ver=${curManifestVersion} tab_url=${url} bash">
    </div>
  `)
  return html
}

function cmdTypesToHtml(cmdTypes, keywordFilter = '') {
  let html = ''
  cmdTypes.forEach(cmdType => {
    const cmds = commands
      .filter(cmd => cmd.envTypes.includes(isCloud ? 'cloud' : 'vm'))
      .filter(cmd => cmd.cmdTypes.includes(cmdType))
      .filter(cmd => matchCmd(cmd, keywordFilter))
    html += `<div id="cmds-container" class="cmds-container grid-${cmdType}" aria-label="${cmdType}">
        ${cmdsToHtml(cmds)}
      </div>`
  })
  return html
}

// $('#cmds-grid').html(cmdTypesToHtml(['magento', 'access', 'debug', 'maintenance']))

function renderCmdsGrid(ev) {
  const key = $('#search-cmds').val()
  $('#cmds-grid').html(cmdTypesToHtml(['magento', 'access', 'debug', 'maintenance'], key))
}

$('body').on('click', '.cli-cmd-container', function (ev) {
  const jCmdInput = $(this).find('input')
  copyToClipboard(jCmdInput)
  trackEvent($(this))
})

$('body').on('keyup', '#search-cmds', renderCmdsGrid)
renderCmdsGrid()