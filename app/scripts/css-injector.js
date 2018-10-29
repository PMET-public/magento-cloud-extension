const jCssUrlInput = $('#css-url-input'),
  jCssUrlSave = $('#css-url-save'),
  jCssUrlDelete = $('#css-url-delete'),
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



jCssUrlSave.click(function () {
  jCssNameDialog.dialog('open')
})

jCssDropDownButton.click(function (ev) {
  jCssUrlInput.focus()
})

jCssPowerButton.click(function (ev) {
  const isOn = $(this).toggleClass('on').is('.on')
  chrome.storage.local.set({isCssInjectorOn: isOn ? true : false})
  handleExtensionIcon()
  handleCssInput()
})

jCssClearInputButton.click(function (ev) {
  jCssUrlInput.val('').prop('disabled', false).focus()
  handleCssInput()
})

// get list of css files in repo via API
// note: anonymous API limited to 60 requests / hr / IP (should be sufficient)
fetch('https://api.github.com/repos/PMET-public/magento-sc-custom-demo-css/contents/')
  .then(response => response.json())
  .then(files => files.filter(file => /\.css$/i.test(file.name)))
  .then(repoCssFiles => {
    chrome.storage.local.set({'repoCssFiles': repoCssFiles})
  })

// user saved urls
chrome.storage.local.get(['cssUrls'], function (result) {
  const cssUrls = result['cssUrls']
  if (typeof cssUrls === 'undefined') return
  let mostRecent = null
  Object.entries(cssUrls).forEach(([key, obj]) => {
      if (mostRecent === null) {
          mostRecent = key
      } else {
          if (obj.timestamp > cssUrls[mostRecent].timestamp) {
              mostRecent = key
          }
      }
  });
  jCssUrlInput[0].value = cssUrls[mostRecent].rawUrl
});

// initialize view
$(function () {
  chrome.storage.local.get(['isCssInjectorOn'], function (result) {
    if (result['isCssInjectorOn']) {
      jCssPowerButton.addClass('on')
    } else {
      jCssPowerButton.removeClass('on')
    }
  })
  const appliedDomain = tabDomain.replace(/.*\/\//,'')
  $('#css-url-applied-domain').text(appliedDomain)


})