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
  
  $('#css-url-applied-domain').text(appliedDomain)

})