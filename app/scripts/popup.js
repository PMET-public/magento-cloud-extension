var tabDomain = null;
chrome.tabs.query({active: true, currentWindow: true}, function(tabs) {
  var tabUrl = tabs[0].url;
  tabDomain = tabUrl.substring(0,tabUrl.indexOf('/', 8))
});

$(function() {
  var tabs = $('#tabs').tabs()
})
