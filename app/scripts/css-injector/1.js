const jCssUrlInput = $('#css-url-input'),
  jCssUrlSave = $('#css-url-save'),
  jCssUrlDelete = $('#css-url-delete'),
  jCssUrlAppliedDomain = $('#css-url-applied-domain'),
  jCssPowerButton = $('#css-injector-toggler .mdi-power'),
  jCssDropDownButton = $('.mdi-arrow-down-drop-circle-outline'),
  jCssClearInputButton = $('.mdi-close-circle-outline'),
  jCssNameDialog = $('#css-name-dialog'),
  jCssNameDialogInput = $('#css-name-dialog-input')

function handleCssInput(ev, ui) {
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
      //curCssUrl = ui.item.value.replace(/.*?(https:\/\/)/, '$1')
      chrome.storage.local.set({curCssUrl: ui.item.value})
      jCssUrlInput.val(ui.item.label).prop('disabled', true)
    }
  }

  // show diff input buttons based on input val
  if (jCssUrlInput.val()) {
    jCssDropDownButton.hide()
    jCssClearInputButton.show()
  } else {
    jCssDropDownButton.show()
    jCssClearInputButton.hide()
  }

  // always remove but possibly load changed css
  chrome.storage.local.get(['isCssInjectorOn', 'curCssUrl'], function (result) {
    chrome.tabs.executeScript({file: 'scripts/lib-for-document.js'}, function () {
      chrome.tabs.executeScript({code: 'MCExt.removeCSS()'})
      if (result['isCssInjectorOn']) {
        if (result['curCssUrl']) {
          chrome.tabs.executeScript({code: 'MCExt.loadCSS(\'' + result['curCssUrl'] + '\')'})
        }
      }
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
  
  .text(appliedDomain)

})