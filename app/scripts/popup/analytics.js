// Using localStorage to store the client ID in order to track users across sessions
// https://developers.google.com/analytics/devguides/collection/analyticsjs/cookies-user-id#using_localstorage_to_store_the_client_id
// will need to change this to our own style and to use chrome.storage.local instead of localStorage.
let GA_LOCAL_STORAGE_KEY = 'ga:clientId',
  trackingId = isDevForGA ? 'UA-133691543-6' : 'UA-133691543-6'

if (window.localStorage) {
  ga('create', trackingId, {
    'storage': 'none',
    'clientId': localStorage.getItem(GA_LOCAL_STORAGE_KEY)
  })
  ga(function(tracker) {
    localStorage.setItem(GA_LOCAL_STORAGE_KEY, tracker.get('clientId'))
  })
} else {
  ga('create', trackingId, 'auto')
}

// removes necessary check against http or https since the protocol is 'chrome-extension://'
ga('set', 'checkProtocolTask', null)

ga('send', 'event', 'mceOpen', 'mceOpen', chrome.runtime.getManifest().version, {nonInteraction: true})

// tracks simple click on buttons
function trackEvent(element) {

  let parentId = element[0].parentElement.id,
    category = 'Commands - ' + element.parent()[0].ariaLabel,
    label = chrome.runtime.getManifest().version,
    action,
    rest

  // gets command's button name
  [action, rest] = element[0].innerText.trim().split('\n')

  // check if button belongs to the commands tab
  if (parentId === 'cmds-container') {
    ga('send', 'event', category, action, label)
  }
}