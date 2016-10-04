window.Codemarathon ||= {}

# remove attachment field
window.Codemarathon.removeField = (link) ->
  $(link).prev("input[type=hidden]").val("true")
  tag = $(link).closest("li")
  tag.hide("fade in").addClass("deleted")

# add attachment field
window.Codemarathon.addField = (link, association, content) ->
  new_id = new Date().getTime()
  regexp = new RegExp("new_" + association, "g")
  html = $(content.replace(regexp, new_id)).hide()
  html.appendTo($(link).closest("div.field").find("ul").first()).slideDown("slow")

$ ->
  $(document).on('change', 'input[type=radio].question-type', ->
    console.log("here")
    if $(this).val() == 'multiple'
      $(this).closest('.field').children('.freetext-answer').hide()
      $(this).closest('.field').children('span.multiple-answers').show()
    else
      $(this).closest('.field').children('span.multiple-answers').hide()
      $(this).closest('.field').children('.freetext-answer').show()
  )
