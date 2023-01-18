const jCssUrlInput = $('#css-url-input'),
  jCssUrlSave = $('#css-url-save'),
  jCssUrlDelete = $('#css-url-delete'),
  jCssPowerButton = $('#css-injector-toggler .mdi-power'),
  jCssDropDownButton = $('.mdi-arrow-down-drop-circle-outline'),
  jCssClearInputButton = $('.mdi-close-circle-outline'),
  jCssNameDialog = $('#css-name-dialog'),
  jCssNameDialogInput = $('#css-name-dialog-input')

function handleCssInjector(ev, ui) {
  jCssUrlInput.val(jCssUrlInput.val().trim())
  if (ev) {
    if (ev.type === 'change') {
      if (jCssUrlInput.val().indexOf('https://') !== 0) {
        jCssUrlInput.val('')
        $('#css-url-error-msg').show().fadeOut(2000)
      } else {
        $('#css-url-error-msg').hide()
        chrome.storage.local.set({curCssUrl: jCssUrlInput.val()})
      }
    } else if (ev.type === 'advautocompletechange') {
      // curCssUrl = ui.item.value.replace(/.*?(https:\/\/)/, '$1')
      if (typeof ui !== 'undefined' && typeof ui.item !== 'undefined') {
        chrome.storage.local.set({curCssUrl: ui.item.value})
        jCssUrlInput.val(ui.item.label).prop('disabled', true)
      }
    }
  }

  // show diff input buttons based on input val
  if (jCssUrlInput.val()) {
    jCssDropDownButton.hide()
    jCssClearInputButton.show()
    jCssUrlSave.prop('disabled', false)
  } else {
    jCssDropDownButton.show()
    jCssClearInputButton.hide()
    chrome.storage.local.set({curCssUrl: null})
    jCssUrlSave.prop('disabled', true)
  }

  // always remove but possibly load changed css
  chrome.windows.getCurrent(function (currentWindow) {
    chrome.tabs.query({ active: true, windowId: currentWindow.id }, function (activeTabs) {
      chrome.storage.local.get(['isCssInjectorOn', 'curCssUrl'], function (result) {
        chrome.scripting.executeScript({target: {tabId: activeTabs[0].id}, files: ['scripts/content.processed.js']}, function () {
          chrome.scripting.executeScript({target: {tabId: activeTabs[0].id}, function: function () { MCExt.removeCSS() }})
          if (result['isCssInjectorOn']) {
            if (result['curCssUrl']) {
              chrome.scripting.executeScript({target: {tabId: activeTabs[0].id}, function: function (css) { MCExt.loadCSS(css) }, args: [result['curCssUrl']]})
            }
          }
        })
      })
    })
  })
}

// initialize view
$(function () {
  chrome.storage.local.get(['isCssInjectorOn'], function (result) {
    if (result['isCssInjectorOn']) {
      jCssPowerButton.addClass('on')
    } else {
      jCssPowerButton.removeClass('on')
    }
  })
  handleCssInjector()
})
