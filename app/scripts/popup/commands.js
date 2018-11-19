function isEmailValid(emailVal) {
  return /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/.test(emailVal)
}

function isUserValid(userVal) {
  if (userVal === 'admin') {
    

  }
  return userVal.length > 1
}

function isPasswordValid(passwordVal) {
  return /^[A-z0-9]{7,}$/.test(passwordVal) && /[0-9]/.test(passwordVal) && /[A-z]/.test(passwordVal)
}

function setFormButtonState() {
  const emailPassed = isEmailValid($('#email-dialog-input').val())
  const passed = emailPassed &&
    isUserValid($('#user-dialog-input').val()) &&
    isPasswordValid($('#password-dialog-input').val())
  $('#password-dialog ~ .ui-dialog-buttonpane button').button(passed ? 'enable' : 'disable')
  // special case for "admin" user in cloud
  if (/magento(site)?\.cloud/.test(tabBaseUrl) && emailPassed && $('#user-dialog-input').val() === 'admin' && $('#email-dialog-input').val() !== 'kbentrup@magento.com') { 
    if (!$('#admin-reset-note').length) {
      $('#password-dialog').prepend(
        '<p id="admin-reset-note">Note: By default, cloud environments were created with the "admin" account ' +
        'assigned to "kbentrup@magento.com". If the default email has not been changed, this UI will let you ' +
        '<b>CHANGE THE PASSWORD ONLY</b> for that username &amp; email ' + 
        'pair. To change the email for "admin" you will have to log into the /admin site.</p>'
      )
    }
  } else {
    $('#admin-reset-note').remove();
  }
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
    collapsible: true,
    heightStyle: "content"
  })
  
  $('#password-dialog').dialog({
    autoOpen: false,
    modal: true,
    draggable: false,
    resizable: false,
    width: 400,
    buttons: [
      {
        text: 'Ok',
        click: function () {
          $( this ).dialog('close')
          const jCmdInput = $('#password-cli-cmd')
          jCmdInput.val(
            jCmdInput.val()
              .replace(/email=[^ ]+/, 'email=' + $('#email-dialog-input').val())
              .replace(/user=[^ ]+/, 'user=' + $('#user-dialog-input').val())
              .replace(/password=[^ ]+/, 'password=' + $('#password-dialog-input').val())
              .trim()
            )
          copyToClipboard(jCmdInput)
        }
      }
    ]
  })
  
  $('#email-dialog-input').on('keyup blur', function () {
    const errorClass = 'has-error'
    const emailVal = $(this).val().trim()
    $(this).val(emailVal)
    // js email regex from https://stackoverflow.com/questions/201323/how-to-validate-an-email-address-using-a-regular-expression
    // exclude local valid emails (emails w/o TLDs)
    if (isEmailValid(emailVal)) {
      $(this).removeClass(errorClass)
    } else {
      $(this).addClass(errorClass)
    }
    setFormButtonState()
  })

  $('#user-dialog-input').on('keyup blur', function () {
    const errorClass = 'has-error'
    const userVal = $(this).val().replace(/[^A-z0-9]/g,'')
    $(this).val(userVal)
    if (isUserValid(userVal)) {
      $(this).removeClass(errorClass)
    } else {
      $(this).addClass(errorClass)
    }
    setFormButtonState()
  })

  $('#password-dialog-input').on('keyup blur', function () {
    const errorClass = 'has-error'
    const passwordVal = $(this).val().replace(/[^A-z0-9]/g,'')
    $(this).val(passwordVal)
    if (isPasswordValid(passwordVal)) {
      $(this).removeClass(errorClass)
    } else {
      $(this).addClass(errorClass)
    }
    setFormButtonState()
  })
  
  $('.cli-cmd').each(function () {
    const jCmdInput = $(this)
    // if url is part of magento.cloud (not magentosite.cloud or VM), use full url else just base url
    const url = /magento\.cloud/.test(tabBaseUrl) ? tabUrl : tabBaseUrl
    jCmdInput.val(jCmdInput.val().replace('{{url}}', url))
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
