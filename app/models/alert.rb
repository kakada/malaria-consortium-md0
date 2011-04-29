class Alert < ActiveRecord::Base
  belongs_to :recipient, :class_name => "Place"
  belongs_to :source, :class_name => "Place"
  
  after_initialize :set_defaults
  
  Types = ["HealthCenter", "Village"]

  Types.each do |constant|
    # Define classes for each kind of alert
    class_eval %Q(
      class ::#{constant}Alert < Alert
        default_scope where(:source_type => "#{constant}")
      end
    )
  end
  
  def source_description
    HealthCenterAlert.all
    
    return source.description if source
    "All"
  end
  
  private
  
  def set_defaults
    self.threshold  ||= 0
  end
end
