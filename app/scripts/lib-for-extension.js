function handleExtensionIcon() {
  chrome.storage.local.get(['isCssInjectorOn'], function (result) {
    const isOn = result['isCssInjectorOn']
    chrome.browserAction.setBadgeText({text: isOn ? 'on' : ''})
    chrome.browserAction.setIcon({
      path: {
        '16': '../images/cloud-' + (isOn ? '' : 'disabled-') + '16.png',
        '24': '../images/cloud-' + (isOn ? '' : 'disabled-') + '24.png',
        '32': '../images/cloud-' + (isOn ? '' : 'disabled-') + '32.png',
        '48': '../images/cloud-' + (isOn ? '' : 'disabled-') + '48.png'
      }
    })
  })
}
