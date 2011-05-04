class Alert < ActiveRecord::Base
  belongs_to :recipient, :class_name => "Place"
  belongs_to :source, :class_name => "Place"
  
  validates_presence_of :recipient_id
  validate :recipient_type_is_od
  
  after_initialize :set_defaults
  
  def source_description
    return source.description if source
    "All"
  end
  
  def self.generate_for recipient, source 
    generated_alerts = []
    
    alerts_for(recipient, source).each do |alert|
      generated_alerts.push(:message => alert.message, :recipients => recipient.users) if alert.reached_condition?
    end
    
    generated_alerts
  end

  def self.alerts_for recipient, source
    Alert.where("recipient_id = ? AND (source_id IS NULL OR source_id = ?)", recipient.id, source.id)
  end

  def reached_condition?
    if source == nil
      recipient.count_reports_since(7.days.ago) >= threshold
    else
      source.count_sent_reports_since(7.days.ago) >= threshold
    end
  end
  
  def message
    "There were more than #{threshold} cases in #{source_description} during the last 7 days"
  end
  
  private
  
  def set_defaults
    self.threshold  ||= 0
  end
  
  def recipient_type_is_od
    errors.add(:recipient_id, "Recipient must be an OD") unless self.recipient && self.recipient.od?    
  end
end