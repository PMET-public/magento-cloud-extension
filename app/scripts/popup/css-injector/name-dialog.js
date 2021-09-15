jCssNameDialog.dialog({
  autoOpen: false,
  modal: true,
  draggable: false,
  resizable: false,
  buttons: [{
    text: 'Ok',
    click: function() {
      $(this).dialog('close')
      chrome.storage.local.get(['cssUrls'], result => {
        const cssUrls = result['cssUrls'] || {}
        cssUrls[appliedDomain] = {
          name: jCssNameDialogInput.val().trim(),
          timestamp: new Date() / 1000,
          rawUrl: jCssUrlInput.val(),
          cached: true
        }
        chrome.storage.local.set({cssUrls: cssUrls})
        jCssUrlDelete.show()
      })
    }
  }],
  open: function (ev) {
    chrome.storage.local.get(['cssUrls'], result => {
      const cssUrl = jCssUrlInput.val(),
        cssUrls = result['cssUrls'] || {}
      if (typeof cssUrls[appliedDomain] !== 'undefined' && cssUrls[appliedDomain].name) {
        jCssNameDialogInput.val(cssUrls[appliedDomain].name)
      }
    })
  }
})