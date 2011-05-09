class String
  def with_sms_protocol
    "sms://#{self}"
  end

  def without_protocol
    split('://', 2)[1]
  end

  def apply(values)
    values = values.with_indifferent_access
    self.gsub /\{[^\}]*\}/ do |key|
      values[key[1..-2].to_sym] || '??'
    end
  end
end
