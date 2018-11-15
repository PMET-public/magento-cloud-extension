$(function() {
  $('#tabs').tabs({
    activate: function (event, ui ) {
      // when a tab is clicked, store it as the current active one
      $('.ui-tabs-tab').each(function (i) { 
        if (this === ui.newTab[0]) { 
          chrome.storage.local.set({activeTab: i})
        }
      })
    }         
  })
  // after tabs created, get the last active tab and restore it
  chrome.storage.local.get(['activeTab'], function (result) {
    const activeTab = result['activeTab'] || 0
    if ($('.ui-tabs-tab a').length) {
      $('.ui-tabs-tab a').get(activeTab).click()
    }
  })
  $('.applied-domain').text(appliedDomain)
})
