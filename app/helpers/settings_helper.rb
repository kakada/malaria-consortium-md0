module SettingsHelper
  def parameters_links(key)
    parameters = Templates::ValidParameters[key].map { |x| link_to "{#{x}}", {}, :class => 'parameter_link' }.join ', '
    %Q(<span style="font-size:90%">Parameters: #{parameters}</span>).html_safe
  end
end
