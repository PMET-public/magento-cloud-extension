'use strict'

console.log('MC Demo Content script')

window.MCExt = {
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

chrome.storage.sync.get(['css-url'], function(result) {
    MCExt.loadCSS(result['css-url'])
}); 