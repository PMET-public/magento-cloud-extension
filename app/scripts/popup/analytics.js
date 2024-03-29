let GA_LOCAL_STORAGE_KEY = 'ga:clientId',
  trackingId,
  clientId

if (typeof isDevForGA === 'undefined') {
  trackingId = 'UA-207749832-1'
} else {
  trackingId = 'UA-207749832-2'
}

// Using localStorage to store the client ID in order to track users across sessions
// https://developers.google.com/analytics/devguides/collection/analyticsjs/cookies-user-id#using_localstorage_to_store_the_client_id
// will need to change this to our own style and to use chrome.storage.local instead of localStorage.
if (window.localStorage) {
  ga('create', trackingId, {
    'storage': 'none',
    'clientId': localStorage.getItem(GA_LOCAL_STORAGE_KEY)
  })
  ga(function (tracker) {
    localStorage.setItem(GA_LOCAL_STORAGE_KEY, tracker.get('clientId'))
  })
} else {
  ga('create', trackingId, 'auto')
}

// removes necessary check against http or https since the protocol is 'chrome-extension://'
ga('set', 'checkProtocolTask', null)

// gets the clientId generated by the tracker object, but only when the analytics.js has fully loaded
ga(function (tracker) {
  clientId = tracker.get('clientId')
})

// tracks extension opened events
ga('send', 'event', 'mceOpen', 'mceOpen', chrome.runtime.getManifest().version, {
  'dimension1': clientId,
  'dimension2': new Date().toISOString()
})

// tracks simple click on buttons
function trackEvent(jElement) {

  let parent = jElement[0].parentElement,
    category = 'Commands - ' + parent.ariaLabel,
    label = chrome.runtime.getManifest().version,
    action,
    rest

  // gets command's button name
  [action, rest] = jElement[0].innerText.trim().split('\n')

  if (parent.id === 'cmds-container') {
    ga('send', 'event', category, action, label, {
      'dimension1': clientId,
      'dimension2': new Date().toISOString()
    })
  }
}