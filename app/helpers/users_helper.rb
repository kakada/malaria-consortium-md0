module UsersHelper
  def render_places
    render :partial => 'admin/places'
  end

  def input_cell name, options= {}
    #cssClass = !options.nil? && options[:class] ? "input #{options[:class]}" : "input"

    element = "<td class=\"inputCell\">"
		element << (!options.nil? && options[:password] ? password_field_tag(name, "", options)
		                                                : text_field_tag(name, "",  options ))
		element << "<div class=\"validation_error\"></div>"
		element << "</td>"
		element.html_safe
  end

  def select_cell field, user=nil , options = {}
    element = "<td class=\"inputCell\" >"
    element << select_tag(field ,options_for_select(User::Roles,  (user.nil?)? "":user.send(field)), options )
		element << '<div class="validation_error server">'
    element << ((!user.nil? && user.errors[field]) ? user.errors[field].join(". ") : " ")
  	element << '</div>'
		element << "</td>"
		element.html_safe
  end

  def user_cell user, field, ui_field_name = nil , options = {}
    element = '<td>'
    element << "<input type='hidden' name='user[#{ui_field_name ? ui_field_name : field.to_s}][]' value='#{user.send(field)}'/>"

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

  def input_field_tag field, user, type = "text", options = {}
    element = ""
    if(type.nil?)
      type = "text"
    end
    if(field.to_s == "intended_place_code" )
      element << text_field_tag(field, user.send(field).nil? ? ((user.place.nil?)?"":user.place.code) : user.send(field)  , options )
    else
      if(type == "text" )
        element << text_field_tag(field, user.send(field),options )
      elsif(type=="hidden")
        element << hidden_t_field_tag(field, user.send(field),options )
      elsif(type == "password")
        element << password_field_tag(field, user.send(field),options )
      end
    end

    if(type == "text" || type == "password" )
      if(user.errors[field].size > 0)
        element << "<div class='validation_error' >#{user.errors[field].join(". ")} </div>";
      end
    end
  	element.html_safe
  end
end
