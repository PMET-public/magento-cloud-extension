function isPasswordValid(passwordVal) {
  return /^[A-z0-9]{7,}$/.test(passwordVal) && /[0-9]/.test(passwordVal) && /[A-z]/.test(passwordVal)
}

function copyToClipboard(el) {
  const copyClass = 'copied-to-clipboard-alert'
  const jCopyEl = $(el)
    .focus()
    .select()
    .parent()
    .append('<span class="' + copyClass + '">copied!</span>')
    .find('.' + copyClass)
    .fadeOut(1000, function () {
      $(this).remove()
    })
  document.execCommand('copy')

}

$(function () {
  $('#commands-accordion').accordion({
    active: 1,
    collapsible: true
  })
  $('#password-dialog').dialog({
    autoOpen: false,
    modal: true,
    draggable: false,
    resizable: false,
    buttons: [
      {
        text: 'Ok',
        click: function () {
          $( this ).dialog('close')
          const jCmdInput = $('#password-cli-cmd')
          jCmdInput.val(jCmdInput.val().replace(/password=[^ ]+/, 'password=' + $('#password-dialog-input').val().trim()))
          copyToClipboard(jCmdInput)
        }
      }
    ]
  })
  $('#password-dialog-input').on('keyup', function () {
    const errorClass = 'has-error'
    const passwordVal = $(this).val().replace(/[^A-z0-9]/g,'')
    $(this).val(passwordVal)
    if (isPasswordValid(passwordVal)) {
      $(this).removeClass(errorClass)
      $('#password-dialog ~ .ui-dialog-buttonpane button').button('enable')
    } else {
      $(this).addClass(errorClass)
      $('#password-dialog  ~ .ui-dialog-buttonpane button').button('disable')
    }
  })
  $('.cli-cmd').each(function () {
    const jCmdInput = $(this)
    jCmdInput.val(jCmdInput.val().replace('{{url}}', tabDomain))
      .next('.simple-copy')
      .click(function (ev) {
        copyToClipboard(jCmdInput)
      })
  })
  $('#password-prompt').click(function () {
    $('#password-dialog').dialog('open')
    if (!isPasswordValid($('#password-dialog-input').val())) {
      $('#password-dialog  ~ .ui-dialog-buttonpane button').button('disable')
    }
  })
})
