class CreateMessageFormatTable < ActiveRecord::Migration
  def self.up
    create_table :referal_message_formats do |t|
      t.string   :format
      t.string   :sector
      t.timestamps
    end
    
    Referal::MessageFormat.create! :sector => "HealthCenter"
    Referal::MessageFormat.create! :sector => "Clinic"
    
    
  end

  def self.down
    drop_table :referal_message_formats
  end
end
