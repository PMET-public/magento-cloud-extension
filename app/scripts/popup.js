/*


chrome.storage.sync.get(['key'], function(result) {
  console.log('Value currently is ' + result.key);
}); 
*/
const cu = document.getElementById('css-url')
document.getElementById('css-url').addEventListener('click', function () {
    console.log('MC D Popup')
    chrome.storage.sync.set({key: value}, function() {
        console.log('Value is set to ' + value);
    });
});