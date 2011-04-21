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
end
