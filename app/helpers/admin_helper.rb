module AdminHelper
  
  def render_places
    render :partial => 'admin/places'
  end
  
  def input_cell name, options=nil
    cssClass = !options.nil? && options[:class] ? "input #{options[:class]}" : "input"
    
    element = "<td class=\"inputCell\">"
		element << (!options.nil? && options[:password] ? password_field_tag(name, "", :class => cssClass)
		                                                : text_field_tag(name, "", :class => cssClass))
		element << "<div class=\"validation_error\"></div>"
		element << "</td>"
		element.html_safe
  end
  
  def user_cell user, field, ui_field_name = nil
    p user.intended_place_code
    element = '<td>'
    element << "<input type='hidden' name='admin[#{ui_field_name ? ui_field_name : field.to_s}][]' value='#{user.send(field)}'/>"
    element << user.send(field)
    element << '<div class="validation_error server">'
    element << (user.errors[field] ? user.errors[field].join(". ") : "")
  	element << '</div>'
  	element << '</td>'
  	element.html_safe
  end
end
