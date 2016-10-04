module QuizHelper
  def link_to_remove_field(name, f)
    f.hidden_field(:_destroy) +
    __link_to_function(raw(name), "window.Codemarathon.removeField(this)",
      class: "btn btn-small btn-default remove-element")
  end

  def link_to_add_field(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    __link_to_function(name, "window.Codemarathon.addField(this, \"#{association}\", \"#{escape_javascript(fields)}\")",
      id: "add-attach", class: "btn btn-small btn-default")
  end

  private

  def __link_to_function(name, on_click_event, opts={})
    link_to(name, 'javascript:;', opts.merge(onclick: on_click_event))
  end
end
