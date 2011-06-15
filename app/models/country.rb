class Country < Place
  def self.national
    first || create_national!
  end

  def self.create_national!
    create! :name => 'National', :code => '', :lat => 12.71536762877211, :lng => 104.8974609375
  end
end
