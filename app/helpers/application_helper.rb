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
end
