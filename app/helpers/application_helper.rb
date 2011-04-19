module ApplicationHelper
  def title
		pref = "Malaria alert system"
		if !@title.nil?
			return pref + " | "+ @title
		end
		return pref
	end
  
end
