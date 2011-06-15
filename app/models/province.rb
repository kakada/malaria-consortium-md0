class Province < Place
  alias_method :country, :parent
  has_many :ods, :class_name => "OD", :foreign_key => "parent_id"
  before_save :assign_national_country, :unless => :parent_id?

  private

  def assign_national_country
    self.parent = Country.national
  end
end
