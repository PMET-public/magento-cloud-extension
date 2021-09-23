// Using localStorage to store the client ID in order to track users across sessions
// https://developers.google.com/analytics/devguides/collection/analyticsjs/cookies-user-id#using_localstorage_to_store_the_client_id
// will need to change this to our own style and to use chrome.storage.local instead of localStorage.
let GA_LOCAL_STORAGE_KEY = 'ga:clientId',
  trackingId

if (typeof isDevForGA === 'undefined') {
  trackingId = 'UA-207749832-1'
} else {
  trackingId = 'UA-207749832-2'
}

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

// get the clientId
let clientId = function() {
    try {
      let trackers = ga.getAll(),
        i, len
      for (i = 0, len = trackers.length; i < len; i += 1) {
        if (trackers[i].get('trackingId') === trackingId) {
          return trackers[i].get('clientId')
        }
      }
    } catch (e) {
      console.log(e)
    }
    return false
  },
  // generate and return local time as ISO string with offset at the end
  timestamp = function() {
    let now = new Date(),
      tzo = -now.getTimezoneOffset(),
      dif = tzo >= 0 ? '+' : '-',
      pad = function(num) {
        let norm = Math.abs(Math.floor(num))
        return (norm < 10 ? '0' : '') + norm
      }
    return now.getFullYear()
      + '-' + pad(now.getMonth() + 1)
      + '-' + pad(now.getDate())
      + 'T' + pad(now.getHours())
      + ':' + pad(now.getMinutes())
      + ':' + pad(now.getSeconds())
      + '.' + pad(now.getMilliseconds())
      + dif + pad(tzo / 60)
      + ':' + pad(tzo % 60)
  }

ga('send', 'event', 'mceOpen', 'mceOpen', chrome.runtime.getManifest().version, {
  'dimension1': clientId(),
  'dimension2': timestamp()
})

// tracks simple click on buttons
function trackEvent(element) {

  let parentId = element[0].parentElement.id,
    category = 'Commands - ' + element.parent()[0].ariaLabel,
    label = chrome.runtime.getManifest().version,
    action,
    rest

  // gets command's button name
  [action, rest] = element[0].innerText.trim().split('\n')

  if (parentId === 'cmds-container' && clientId() !== false ) {
    ga('send', 'event', category, action, label, {
      'dimension1': clientId(),
      'dimension2': timestamp()
    })
  }
}