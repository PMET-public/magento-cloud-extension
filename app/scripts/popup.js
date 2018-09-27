const cssUrlInput = $('#css-url-input'),
  cssUrlSave = $('#css-url-save')

function getRawUrl(url) {
  const rawUrl = url.replace(/(https:\/\/github.com.*\/)blob\//,'$1raw\/');
  return rawUrl
  // $.ajax({
  //   url: url,
  //   type: 'GET',
  //   success: data => {
  //     data
  //   }
  // })
}

function initInput(result) {
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
  cssUrlInput[0].value = cssUrls[mostRecent].rawUrl
}

chrome.storage.sync.get(['cssUrls'], initInput);

cssUrlInput.change(ev => {
  cssUrlInput[0].value = cssUrlInput.val().trim()
  // if (cssUrlInput[0].value.indexOf('https://') !== 0) {
  //   alert('Invalid url. Must start with https://.')
  //   cssUrlInput[0].value = ''
  // }
  // const rawUrl = getRawUrl(ev.target.value)
  // if (rawUrl === '') {
  //   chrome.tabs.executeScript(null, {code: "window.MCExt.removeCSS()"})
  // } else {
  //   chrome.tabs.executeScript(null, {code: "window.MCExt.loadCSS('" + rawUrl + "')"})
  // }
}).autocomplete(
  {
    minLength: 0,
    select: (ev, ui) => {
      if (cssUrlInput.val() !== ui.item.value) {
        const rawUrl = getRawUrl(ui.item.value)
        chrome.tabs.executeScript(null, {code: "window.MCExt.removeCSS()"});
        chrome.tabs.executeScript(null, {code: "window.MCExt.loadCSS('" + rawUrl + "')"})
      }
    },
    source: (req, resp) => {
      chrome.storage.sync.get(['cssUrls'], result => {
        let cssUrls = result['cssUrls']
        if (typeof cssUrls === 'undefined') {
          resp([
            {label: 'No saved urls.', value: ''}
          ])
          return
        }
        const term = req.term.toLowerCase()
        const options = []
        Object.entries(cssUrls).forEach(([key, obj]) => {
          if (obj.name.toLowerCase().indexOf(term) >= 0  || obj.rawUrl.toLowerCase().indexOf(term) >= 0) {
            const label = obj.name + ' (saved: ' + new Date(obj.timestamp * 1000).toLocaleDateString(navigator.language) + ') ' + key
            options.push({label: label, value: obj.rawUrl})
          }
        })
        options.sort((a, b) => {
          return b.timestamp - a.timestamp
        })
        resp(options)
      })
    }
  }
)

cssUrlSave.click((ev) => {
  chrome.storage.sync.get(['cssUrls'], result => {
    const cssUrl = cssUrlInput.val()
    const cssUrls = result['cssUrls'] || {}
    if (typeof cssUrls === 'undefined' || typeof cssUrls[cssUrl] === 'undefined') {
      let name = '',
        cssUrls = {}

    } else {
      name = cssUrls[cssUrl].name
    }
    name = prompt('Give your stylesheet a name:', name)
    cssUrls[cssUrl] = {
      name: name,
      timestamp: new Date()/1000,
      rawUrl: getRawUrl(cssUrlInput.val())
    }
    chrome.storage.sync.set({cssUrls: cssUrls})
  });
})

$( function() {
  var tabs = $( "#tabs" ).tabs();
} );
