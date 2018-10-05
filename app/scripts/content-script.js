'use strict'

console.log('MC Demo Content script')

const MCExt = {
  loadCSS: function (url) {
    url = url.replace(/gist.githubusercontent.com|raw.githubusercontent.com|raw.githubusercontent.com/i,'rawgit.com')
    $('#css-url').remove()
    $('<link>', {
      id: 'css-url',
      rel: 'stylesheet',
      type: 'text/css',
      href: url
    }).appendTo('head');
  },
  removeCSS: function () {
    $('#css-url').remove()
  }

}

function getDomain(url) {
  return getOrigin(url).replace(/.*\/\//,'').replace(/:.*/,'')
}

function getOrigin(url) {
  return url.substring(0,url.indexOf('/', 8))
}

// chrome.storage.sync.get(['cssUrls'], function(result) {
//   const cssUrls = result['cssUrls'] || {}
//   const domain = getDomain(location.href)
//   if (cssUrls[domain] && cssUrls[domain].rawUrl) {
//     MCExt.loadCSS(cssUrls[domain].rawUrl)
//   }
// }); 