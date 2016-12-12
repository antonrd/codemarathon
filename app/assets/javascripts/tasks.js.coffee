window.Codemarathon ||= {}

$ ->
  window.Codemarathon.source_code = {}

  initialize_code_area("source-code-editor", "source_code", gon.last_programming_language, true)
  initialize_code_area("cpp-boilerplate", "task[cpp_boilerplate]", "cpp", false)
  initialize_code_area("cpp-wrapper", "task[cpp_wrapper]", "cpp", false)
  initialize_code_area("java-boilerplate", "task[java_boilerplate]", "java", false)
  initialize_code_area("java-wrapper", "task[java_wrapper]", "java", false)
  initialize_code_area("python-boilerplate", "task[python_boilerplate]", "python", false)
  initialize_code_area("python-wrapper", "task[python_wrapper]", "python", false)
  initialize_code_area("ruby-boilerplate", "task[ruby_boilerplate]", "ruby", false)
  initialize_code_area("ruby-wrapper", "task[ruby_wrapper]", "ruby", false)

  $('[data-toggle="popover"]').popover()

initialize_code_area = (field_id, text_area_name, language, language_change) ->
  language = "cpp" unless language

  window.Codemarathon.source_code[field_id] = {}

  if $("#" + field_id).length > 0
    editor = ace.edit(field_id)
    editor.setTheme("ace/theme/textmate")
    editor.getSession().setMode("ace/mode/" + ace_theme_name(language))
    editor.$blockScrolling = Infinity

    textarea = $('textarea[name="' + text_area_name + '"]').hide()
    editor.getSession().setValue(textarea.val())

    editor.getSession().on('change', ->
      textarea.val(editor.getSession().getValue())
      curr_lang = $('select[name=lang]').val()
      window.Codemarathon.source_code[field_id][curr_lang] = textarea.val()
    )

    if gon[language + "_boilerplate"]
      editor.getSession().setValue(gon[language + "_boilerplate"])
    else
      $('.load-boilerplate-code').hide()

    if $('.load-boilerplate-code').length > 0
      $('.load-boilerplate-code').on('click', ->
        if confirm("Are you sure you want to reset the current code?")
          curr_lang = $('select[name=lang]').val()
          editor.getSession().setValue(gon[curr_lang + "_boilerplate"])
      )

    if language_change
      $('select[name=lang]').on('change', ->
        # Set the mode for the editor
        editor.getSession().setMode("ace/mode/" + ace_theme_name(this.value))

        # Show the button for realoading the boilerplate code, if there is boilerplate code
        if gon[this.value + "_boilerplate"]
          $('.load-boilerplate-code').show()
        else
          $('.load-boilerplate-code').hide()

        # For tasks that are of the I/O files type, for Java load a message indicating what
        # the name of the main class must be.
        unless gon.with_unit_tests
          $('.java-info').addClass('hidden')
          $('.java-info').removeClass('hidden') if this.value == 'java'

        # Change the source code to correspond to the selected language
        curr_lang = this.value
        if window.Codemarathon.source_code[field_id][curr_lang]?
          editor.getSession().setValue(window.Codemarathon.source_code[field_id][curr_lang])
        else if gon[curr_lang + "_boilerplate"]?
          editor.getSession().setValue(gon[curr_lang + "_boilerplate"])
      )

ace_theme_name = (select_value) ->
  if select_value == "cpp"
    return "c_cpp"
  else
    return select_value
