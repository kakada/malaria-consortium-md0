module Referal
  module ReferalHelper
  	def referal_title
		@referal_title ? "#{@referal_title}-#{referal_app}": referal_app		
	end

	def referal_app
		@referal_app ? @referal_app : "Referal system"
	end

	def breadcrumb_str options
		items = []
		char_sep = "&raquo;".html_safe
		if(options.size != 0)
			items <<  content_tag(:li , :class => "active") do
				link_to("Home", referal_root_path) + content_tag(:span, char_sep, :class => "divider")
			end
			options.each do |option|
				option.each do |key, value|
				  if !value.nil?
					items << content_tag(:li) do
						link_to(key, value) + content_tag(:span, char_sep, :class => "divider")
					end 
				  else
					items << content_tag(:li, key, :class =>"active") 
				  end
				end
			end	
		else
			items << content_tag(:li, "Home", :class => "active")	
		end

		items.join("").html_safe
	end

	def breadcrumb options
		content_tag(:ul, breadcrumb_str(options), :class => "breadcrumb")
	end

	def tag_row(options ={}, &block)
      options = self.merge_options(options, :class, "div-row")
      #output = with_output_buffer(&block)
      #content_tag(:div, output, options)
      content_tag(:div, options, &block)
    end

    def merge_options(options, name, value)
      #alert alert-error
      if options[name].nil?
        options.merge!({name => value} ) 
      else
        options[name] = value + " " + options[name]
      end
      options
    end

    def render_errors_for model, options={}
      if(model.errors.size > 0)
        content = content_tag(:span, "Error : the follwing errors must my fixed ", :class => "label label-warning")
        li = ""
        model.errors.full_messages.each do |message|
            li << content_tag(:li, message)
        end
       options = self.merge_options(options, "class", "alert alert-error")
       content << content_tag(:ul, li, {}, false)
       content_tag :div, content, options, false 
      else
      	"" 
      end  
    end
    
    def message_format format
      result = []
      format.split(Referal::MessageFormat::Separator).each do |item|
        result << message_format_item(item)
      end
      result.join(message_format_separator).html_safe
    end
    
    def message_format_separator
      "<span class='separator-format'> #{Referal::MessageFormat::Separator}</span>"
    end
    
    def message_format_item text
      "<a class='remove-sign'> #{text} </a>";
    end

  end
end