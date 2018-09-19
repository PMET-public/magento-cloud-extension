const cuEl = document.getElementById('css-url')

chrome.storage.sync.get(['cssUrls'], function(result) {
    const cssUrls = result['cssUrls']
    if (cssUrls === null) return
    let mostRecent = null
    Object.keys(cssUrls).forEach([key, obj] => {
        if (mostRecent === null) {
            mostRecent = key
        } else {
            if (obj.timestamp > cssUrls.mostRecentUrl.timestamp) {
              mostRecent = key
            }
        }
    });
    cuEl.value = cssUrls.mostRecent.rawUrl
}); 

function testAndLoadCSS(val) {
    if (/https:\/\//i.test(val)) {
        chrome.tabs.executeScript(null, {code: "window.MCExt.loadCSS('" + val + "')"});
        chrome.storage.sync.set({'css-url': val});
    } else if (!val) {
        chrome.tabs.executeScript(null, {code: "window.MCExt.removeCSS()"});
        chrome.storage.sync.set({'css-url': val});
    }
}

cuEl.addEventListener('change', function (ev) {
    ev.target.value = ev.target.value.trim()
    testAndLoadCSS(ev.target.value)
});

$('#css-url-save').click((ev) => {
    prompt('Name this stylesheet:','Existing value')
    testAndLoadCSS(cuEl.value)
})

$('#css-url').autocomplete(
    {appendTo: '#selector-container',
    source: [
        "ActionScript",
        "AppleScript",
        "Asp",
        "BASIC",
        "C",
        "C++",
        "Clojure",
        "COBOL",
        "ColdFusion",
        "Erlang",
        "Fortran",
        "Groovy",
        "Haskell",
        "Java",
        "JavaScript",
        "Lisp",
        "Perl",
        "PHP",
        "Python",
        "Ruby",
        "Scala",
        "Scheme"
      ]}
    )