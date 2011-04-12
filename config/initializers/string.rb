class String
  def with_sms_protocol
    "sms://#{self}"
  end

  def without_protocol
    split('://', 2)[1]
  end
end
