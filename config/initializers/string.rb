class String
  AddressRegexp = %r(^(.*?)://(.*?)$)

  def with_sms_protocol
    "sms://#{without_protocol}"
  end

  def without_protocol
    self =~ AddressRegexp ? $2 : self
  end

  def apply(values)
    values = values.with_indifferent_access
    self.gsub /\{[^\}]*\}/ do |key|
      values[key[1..-2].to_sym] || '??'
    end
  end


  def strip_village_code
    if self =~ /^(\d{8})00$/
      $1
    else
      self
    end 
  end

end
