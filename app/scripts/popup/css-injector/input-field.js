jCssUrlInput
  .focus(ev => {
    if (!$(this).value) {
      jCssUrlInput.advAutocomplete('search')
    }
    jCssDropDownButton.hide()
  })
  .change(handleCssInjector)
  .advAutocomplete({
    minLength: 0,
    select: function (ev, ui) {
      if (ui.item.value === 'placeholder') {
        ev.preventDefault()
      }
      // this is a hack b/c select has not yet changed the input value
      // and firing the autocomplete change handler directly fails
      // appears to be a bug in jquery ui when invoking this._super for customized autocompletes
      setTimeout(() => jCssUrlInput.blur(), 20)
    },
    change: handleCssInjector,
    source: function (req, resp) {
      chrome.storage.local.get(['cssUrls'], result => {
        const cssUrls = result['cssUrls'] || {},
          term = req.term.toLowerCase()
        chrome.storage.local.get(['repoCssFiles'], result => {
          const options = []
          // user urls
          Object.entries(cssUrls).forEach(([key, obj]) => {
            if (obj.name.toLowerCase().indexOf(term) >= 0 || obj.rawUrl.toLowerCase().indexOf(term) >= 0) {
              const label = obj.name + ' (saved: ' + new Date(obj.timestamp * 1000).toLocaleDateString(navigator.language) + ') ' + key
              options.push({label: label, value: obj.rawUrl})
            }
          })
          options.sort((a, b) => {
            return b.timestamp - a.timestamp
          })
          let numSavedOptions = options.length
          if (numSavedOptions) {
            options.unshift({label: 'Your saved CSS', value: 'placeholder'})
          }
          // repo urls
          let repoUrlsAdded = false
          Object.entries(result['repoCssFiles']).forEach(([key, obj]) => {
            if (obj.name.toLowerCase().indexOf(term) >= 0 || obj.download_url.toLowerCase().indexOf(term) >= 0) {
              options.push({label: obj.name.replace(/.css$/i, '').replace(/-/g, ' '), value: obj.html_url})
              repoUrlsAdded = true
            }
          })
          if (repoUrlsAdded) {
            options.splice(numSavedOptions ? numSavedOptions + 1 : 0, 0, {label: 'Shared stylesheets', value: 'placeholder'})
          }
          resp(options)
        })
      })
    }
  })