jq3 = jQuery.noConflict(true)

function afterDOMLoaded() {
  // the relevant elements are <span data-bind="text: nodename"> on the nodes page and <span data-bind="text: name"> on the jobs result page
  // this selector fits both but may need to be updated to accommodate more or be more selective if false positives are found
  let selector = '#layoutBody span[data-bind$="name"]'
  jq3(document.body).append('<div id="acc-node-actions" class="nodefilterlink link-quiet label label-muted" style="padding: 0.8rem" onclick="event.stopPropagation()">Node Action Placeholder</div>')
  jq3(document.body).on('mouseover', selector, function () {
    var nodeEl = jq3(this),
      o = nodeEl.offset(),
      h = nodeEl.outerHeight(),
      [projId, envId] = nodeEl.text().split('::')
    jq3('#acc-node-actions')
      .html(`
        <a target="_blank" href="https://demo.magento.cloud/projects/${projId}/environments/${envId}">
          &nbsp; <svg height="20" width="15" viewBox="0 0 1024 768">
            <path fill="currentColor" d="M640 768H128V258L256 256V128H0v768h768V576H640V768zM384 128l128 128L320 448l128 128 192-192 128 128V128H384z"/>
          </svg>
          Cloud Project
        </a>
        <br>
        <input type="text" size="60" onclick="this.select(); cpToClipboard" value="magento-cloud ssh -p '${projId}' -e '${envId}'"/>
      `)
      .css({
        top: o.top - (6 * h),
        left: o.left + 2 * h,
        position: 'absolute'
      })
      .show()
  }).on('mouseleave', selector, function () {
    jq3('#acc-node-actions').hide()
  })
  jq3('#acc-node-actions').mouseenter(function () {
    jq3('#acc-node-actions').show()
  }).mouseleave(function () {
    jq3('#acc-node-actions').hide()
  })
}

function cpToClipboard(event) {
  try {
    navigator.clipboard.writeText('test').then(function() {
      console.log('copied')
    }, function(error) {
      console.error('error', error)
    })
  } catch (error) {
    console.error('error', error)
  }
  event.stopPropagation()
  return false
}

if(document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded',afterDOMLoaded);
} else {
  afterDOMLoaded();
}
