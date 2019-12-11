const rawGitUrl = 'https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/'
const rawGitPrefix = `${rawGitUrl}${curManifestVersion}/sh-scripts/`
// if url is part of magento.cloud (not magentosite.cloud or VM), use full url else just base url
const url = /magento\.cloud/.test(tabBaseUrl) ? tabUrl : tabBaseUrl

function copyToClipboard(el) {
  const copyClass = 'copied-to-clipboard-alert'
  const jInput = $(el)
    .focus()
    .select()
  const jMsg = jInput.parent()
    .append('<span class="' + copyClass + '">Copied!</span>')
    .find('.' + copyClass)
  setTimeout(() => jMsg.remove(), 1000)
  document.execCommand('copy')
  jInput[0].blur()
}

function matchCmd(cmd, key) {
  const re = new RegExp(key.trim(),'i')
  if(key.trim() === '' || re.test(cmd.text) || re.test(cmd.help) || re.test(cmd.tag)) {
    return true
  }
  return false
}

function cmdsToHtml(cmds) {
  var html = ''
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

function tagsToHtml(tags, keywordFilter = '') {
  var html = ''
  tags.forEach(tag => html += `
    <div class="cmds-container grid-${tag}" aria-label="${tag}">
      ${cmdsToHtml(commands.filter(cmd => cmd.tags.includes(tag)).filter(cmd => matchCmd(cmd, keywordFilter)))}
    </div>
  `)
  return html
}

$('#cmds-grid').html(tagsToHtml(['magento', 'access', 'health', 'maintenance']))

$('body').on('click', '.cli-cmd-container', function (ev) {
  const jCmdInput = $(this).find('input')
  copyToClipboard(jCmdInput)
})

$('body').on('keyup', '#search-cmds', function (ev) {
  const key = $('#search-cmds').val()
  $('#cmds-grid').html(tagsToHtml(['magento', 'access', 'health', 'maintenance'], key))
})
