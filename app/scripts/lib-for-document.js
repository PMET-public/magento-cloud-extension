var MCExt = {
  loadCSS: function (url, cacheBustingEnabled = false) {
    if (cacheBustingEnabled) {
      // add dynamic query parameter
      url += '?ts=' + (new Date() / 1)
      // github needs more than dynamic query parameter
      if (/\/\/github.com/.test(url)) {
        // find latest commit and make request directly
        
      }
    } 
    // if url is a github.com url, use raw github instead of API to avoid limits
    url = url.replace(/\/\/github.com(.*?)\/blob\/(.*)/, '//raw.githubusercontent.com$1/$2')
    this.removeCSS()
    fetch(url).then(function (response) {
      return response.text()
    }).then(function (txt) {
      const styleEl = document.createElement('style')
      styleEl.id = 'css-url'
      styleEl.innerText = txt
      document.head.appendChild(styleEl)
    })
  },
  removeCSS: function () {
    const el = document.querySelector('#css-url')
    if (el) {
      el.remove()
    }
  },
  loadSavedCSS: function () {
    chrome.storage.local.get(['isCssInjectorOn', 'cssUrls'], result => {
      if (result['isCssInjectorOn']) {
        const cssUrls = result['cssUrls'] || {}
        const domain = MCExt.getDomain(location.href)
        if (cssUrls[domain] && cssUrls[domain].rawUrl) {
          MCExt.loadCSS(cssUrls[domain].rawUrl)
        }
      }
    })
  },
  loadInputCSS: function () {
    chrome.storage.local.get(['inputCSS'], result => {

    })
  },
  getDomain: function (url) {
    return this.getOrigin(url).replace(/.*\/\//,'').replace(/:.*/,'')
  },
  getOrigin: function (url) {
    return url.substring(0,url.indexOf('/', 8))
  }
}
