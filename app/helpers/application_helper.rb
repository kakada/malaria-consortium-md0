module ApplicationHelper
  def title
		pref = "Malaria consortium"
		if !@title.nil?
			return @title + " | " + pref
		end
		return pref
	end

  def ob_start &block
    element = capture(&block)
    return element
  end
  
  def action_button icon, title, path
    element = "<div class='icon-wrapper'>"
    element << "<div class='icon'>"
    element << (link_to image_tag(icon) + "<span>#{title}</span>".html_safe, path, :class => "round")
    element << "</div>"
    element << "</div>"
    element.html_safe
  end

  def flash_msg(flash)
    flash ||= {}
    element = ""
    flash.each do |key,value|
      element << "<div class='flash round #{key}'> #{value} </div> "
    end
    element.html_safe
  end
end
