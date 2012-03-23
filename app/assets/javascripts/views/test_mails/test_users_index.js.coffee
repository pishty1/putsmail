class Putsmail.Views.TestMailsIndex extends Backbone.View

  template: JST['test_mails/index']

  events:
    "submit #form_test_email": "sendTest"
    "focus .test_mail_cc input[name='test_mail_users_mail']": "makeVisible"
    "blur  .test_mail_cc input[name='test_mail_users_mail']": "checkFilled"
    "click #button_preview": "preview"
    "click #button_check_mail": "checkMail"
    "keyup input[name='test_mail_users_mail']": "showNextRecipient"

  render: ->
    $(@el).html(@template)
    this

  showNextRecipient: (event) ->
    currentRecipient = $(event.target)
    unless _.isEmpty currentRecipient.val()
      nextRecipient = currentRecipient.parent().parent().next().find("input[name='test_mail_users_mail']")
      if !nextRecipient.is(":visible")
        nextRecipient.parent().parent().show(500)

  checkMail: ->
    event.preventDefault()
    $.noty({text: 'Checking...', speed: 100, closeable: true, type: "alert", layout: "topRight", timeout: false, theme: "mitgux"})
    check = new Putsmail.Models.CheckHtml
    check.save {test_mail: 
         body: $("#test_mail_body").val()}
      wait: true
      success:(model, response) ->
        $("#test_mail_body").val model.get("body")
        checkHtmlView = new Putsmail.Views.CheckHtmlsCreate(model: model)
        $("#html_warnings").html(checkHtmlView.render().el)
        $.noty.close()
      error: (model, response) ->
        $.noty.close()
      #   alert "error"

  preview: ->
    event.preventDefault()
    preview = window.open ""
    preview.document.write $("#test_mail_body").val()

  showCC: (event) ->
    event.preventDefault()
    $(".test_mail_cc").show 500, ->
      firstCc = $(".test_mail_cc input[name='test_mail_users_mail']").first()
      firstCc.focus()
      firstCc.css("opacity", 1)

  makeVisible: (event) ->
    obj = $(event.target)
    obj.parent().parent().css("opacity", 1)

  checkFilled: (event) ->
    obj = $(event.target)
    if not _.isEmpty obj.val()
      obj.parent().parent().css("opacity", 1)
    else
      obj.parent().parent().css("opacity", .5)

  sendTest: (event) ->
    event.preventDefault()
    @clearPreviousErrors()
    thiz = this
    $.noty({text: 'Sending...', speed: 100, closeable: true, type: "alert", layout: "topRight", timeout: false, theme: "mitgux"})
    recipients = _.map $("input[name=test_mail_users_mail]:visible"), 
       (recipient) -> $(recipient).val()
    testMail = new Putsmail.Models.TestMail
    testMail.save {test_mail: 
         body: $("#test_mail_body").val()
         subject: $("#test_mail_subject").val()
         recipients: recipients}
      wait: true
      success:(model, response) -> 
        $.noty.close()
      error: (model, response) -> 
        $.noty.close()
        thiz.handleError(model, response)

  clearPreviousErrors: ->
    $("span.error_message").remove()
    $("div.error").removeClass("error")

  handleError: (model, response) ->
    if response.status == 422
      errors = $.parseJSON(response.responseText)
      for attribute, messages of errors
        for message in messages
          input = $("input[name=#{attribute}], textarea[name=#{attribute}], input[id=#{attribute}]")
          if input.length > 0
            input.parent().parent().addClass("error")
            input.after("<span class=\"help-inline error_message\">#{message}</span>")
