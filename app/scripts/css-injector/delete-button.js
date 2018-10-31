jCssUrlDelete.button({
  create: function (ev) {
    chrome.storage.local.get(['cssUrls'], result => {
      const cssUrls = result['cssUrls'] || {}
      if (typeof cssUrls[appliedDomain] === 'undefined') {
        $(this).hide()
      }
    })
  }
})
.click(function (ev) {
  chrome.storage.local.get(['cssUrls'], result => {
    const cssUrls = result['cssUrls'] || {}
    jCssUrlDelete.hide()
    if (typeof cssUrls[appliedDomain] === 'undefined') {
      delete cssUrls[appliedDomain]
    }
  })
})
