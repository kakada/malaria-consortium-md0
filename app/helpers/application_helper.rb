# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def title
		pref = "Malaria alert system"
		if !@title.nil?
			return pref + " | "+ @title  
		end
		return pref
	end
end
