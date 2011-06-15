module SettingsHelper
  def parameters_links(key)
    parameters = Templates::Keys[key][:params].map { |param| link_to "{#{param}}", 'javascript:void(0)', :class => 'parameter_link', 'data-id' => key }.join ', '
    %Q(<span style="font-size:90%">Parameters: #{parameters}</span>).html_safe
  end
end
