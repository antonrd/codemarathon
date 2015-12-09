# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  if $("#source-code-editor").length > 0
    editor = ace.edit("source-code-editor")
    editor.setTheme("ace/theme/textmate")
    editor.getSession().setMode("ace/mode/c_cpp")

    textarea = $('textarea[name="source_code"]').hide()
    editor.getSession().setValue(textarea.val())
    editor.getSession().on('change', ->
      textarea.val(editor.getSession().getValue())
    )

    $('select[name=lang]').on('change', ->
      console.log(ace_theme_name(this.value))
      editor.getSession().setMode("ace/mode/" + ace_theme_name(this.value))
    )

  $('[data-toggle="popover"]').popover()

ace_theme_name = (select_value) ->
  if select_value == "cpp"
    return "c_cpp"
  else
    return select_value
