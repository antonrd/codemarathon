module HighlightHelper
  def highlight_source_code(source_code, language)
    formatter = Rouge::Formatters::HTMLLegacy.new(css_class: 'highlight')
    lexer = language_lexer(language)
    formatter.format(lexer.lex(source_code))
  end

  protected

  def language_lexer(language)
    case language
    when 'cpp'
      Rouge::Lexers::Cpp.new
    when 'python'
      Rouge::Lexers::Python.new
    when 'ruby'
      Rouge::Lexers::Ruby.new
    when 'java'
      Rouge::Lexers::Java.new
    else
      Rouge::Lexers::PlainText.new
    end
  end
end
