$(function () {
  $('#accordion').accordion({
    active: 1
  })
  $('#password-dialog').dialog({
    autoOpen: false,
    modal: true,
    draggable: false,
    resizable: false,
    dialogClass: 'no-close',
    buttons: [
      {
        text: 'Ok',
        click: function() {
          $( this ).dialog('close')
          const jInput = $('#password-cli-cmd')
          jInput.val(jInput.val().replace('password=[^ ]+', 'password=' + $('#password-dialog-input').val().trim()))
          input = jInput[0]
          input.focus()
          input.select()
          document.execCommand('copy')
        }
      }
    ]
  })
  $('#password-dialog-input').on('keyup', function () {
    const errorClass = 'has-error'
    const passwordVal = $(this).val().replace(/[^A-z0-9]/g,'')
    $(this).val(passwordVal)
    if (!(/^[A-z0-9]{7,}$/.test(passwordVal) && /[0-9]/.test(passwordVal) && /[A-z]/.test(passwordVal) )) {
      $(this).addClass(errorClass)
      $('#password-dialog  ~ .ui-dialog-buttonpane button').button('disable')
    } else {
      $(this).removeClass(errorClass)
      $('#password-dialog ~ .ui-dialog-buttonpane button').button('enable')
    }
  })
  $('.cli-cmd').each(function () {
    const cmdInput = this
    $(this).val($(this).val().replace('{{url}}', tabDomain))
      .next('.simple-copy')
      .click(function () {
        cmdInput.focus()
        cmdInput.select()
        document.execCommand('copy')
      })
  })
  $('#password-prompt').click(function () {
    $('#password-dialog').dialog('open')
  })
})
