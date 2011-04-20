module AdminHelper
  
  def render_places
    render :partial => 'admin/places'
  end
  
  def input_cell name, options=nil
    element = "<td class=\"inputCell\">"
		element << (!options.nil? && options[:password] ? password_field_tag(name, "", :class => "input")
		                                                : text_field_tag(name, "", :class => "input"))
		element << "<div class=\"validation_error\"></div>"
		element << "</td>"
		element.html_safe
  end
end
