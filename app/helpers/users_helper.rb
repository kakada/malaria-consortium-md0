module UsersHelper
  def input_cell name, options= {}
    element = "<td class=\"inputCell\">"
		element << (!options.nil? && options[:password] ? password_field_tag(name, "", options)
		                                                : text_field_tag(name, "",  options ))
		element << "<div class=\"validation_error\"></div>"
		element << "</td>"
		element.html_safe
  end

  
  def user_cell user, field, ui_field_name = nil , options = {}
    element = '<td>'
    element << "<input type='hidden' name='admin[#{ui_field_name ? ui_field_name : field.to_s}][]' value='#{user.send(field)}'/>"
    
    if(options[:password].nil?)
      element << "<span>" <<  user.send(field) << "</span>"
    else
      element << "<span>" << "*" * user.send(field).size << "</span>"
    end
    element << '<div class="validation_error server">'
    element << (user.errors[field] ? user.errors[field].join(". ") : " ")
  	element << '</div>'
  	element << '</td>'
  	element.html_safe
  end
end
