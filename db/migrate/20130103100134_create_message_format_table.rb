class CreateMessageFormatTable < ActiveRecord::Migration
  def self.up
    create_table :referral_message_formats do |t|
      t.string   :format
      t.string   :sector
      t.timestamps
    end
    
    Referral::MessageFormat.create! :sector => "HealthCenter"
    Referral::MessageFormat.create! :sector => "Clinic"
    
    
  end

  def self.down
    drop_table :referral_message_formats
  end
end
