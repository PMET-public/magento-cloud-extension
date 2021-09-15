$.widget( 'custom.advAutocomplete', $.ui.autocomplete, {
  _renderItem: function (ul, item) {
    let jItem = this._super(ul, item)
    if (/^placeholder/.test(item.value)) {
      jItem.addClass('ui-menu-placeholder-item')
    }
    let url = item.value.replace(/.*?(https:\/\/)/, '$1')
    if (/^https/.test(url)) {
      jItem.find('div').append('<a target="_blank" href="' + url + '"><span class="mdi mdi-open-in-new"></span></a>')
    }
    return jItem
  }
})