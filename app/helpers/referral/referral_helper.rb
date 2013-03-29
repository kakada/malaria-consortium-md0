module Referral
  module ReferralHelper
  	def referral_title
		@referral_title ? "#{@referral_title}": referral_app		
	end

	def referral_app
		@referral_app ? @referral_app : "Referral system"
	end
  
  def current_url url, options = {}, format="csv"
     url_components = url.split("?")
     uri = url_components[0]
     url_params = []
  
     if url_components.size >1
        url_params << url_components[1]
     end 
     
     options.each do |key, value|
         url_params << URI::escape(key)+ "=" + URI::escape(value)
     end
     query_string = url_params.join("&")
     return uri + "." + format if query_string.blank?
     return uri + "." + format + "?" + query_string
  end

	def breadcrumb_str options
		items = []
		char_sep = "&raquo;".html_safe
		if(options.size != 0)
			items <<  content_tag(:li , :class => "active") do
				link_to("Home", referral_root_path) + content_tag(:span, char_sep, :class => "divider")
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
  
  def register_bar label="", url="", options={}
    content_tag :div, options do
      if block_given?
        yield
      else
        register_btn label, url
      end
      
    end
  end
  
  def register_btn label, url, options={}
     options[:class] = options[:class].nil? ? "btn" : "btn #{options[:class]}"
     link_to "<i class='icon-user  icon-plus' ></i>#{label}".html_safe, url, options
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
      format.split(Referral::MessageFormat::Separator).each do |item|
        result << message_format_item(item)
      end
      result.join(message_format_separator).html_safe
    end
    
    def message_format_separator
      "<span class='separator-format'> #{Referral::MessageFormat::Separator}</span>"
    end
    
    def message_format_item text
      "<a class='remove-sign'> #{text} </a>";
    end
    
    def list_header title, records
       content_tag :div,:class => "row-fluid" do
         
          content_title = content_tag :div, :class => "span4" do
            content_tag(:h3, title)
          end

          content_paginate = content_tag :div, :class => "paginate span8" do
            will_paginate records, :gap => "<li><span>...</span></li>"
          end
          
          (content_title + content_paginate)  
        
       end
    end

  end

end