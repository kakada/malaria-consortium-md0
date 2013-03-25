class AddForeignKeysToReferralReportsTable < ActiveRecord::Migration
  def self.up
    
    execute <<-SQL
      ALTER TABLE referral_reports
        ADD CONSTRAINT referral_reports_sender_id_fk
        FOREIGN KEY (sender_id)
        REFERENCES users(id)
    SQL
    
    execute <<-SQL
      ALTER TABLE referral_reports
        ADD CONSTRAINT referral_reports_confirm_from_id_fk
        FOREIGN KEY (confirm_from_id)
        REFERENCES referral_reports(id)
    SQL
    
    execute <<-SQL
      ALTER TABLE referral_reports
        ADD CONSTRAINT referral_reports_place_id_fk
        FOREIGN KEY (place_id)
        REFERENCES places(id)
    SQL
    
    execute <<-SQL
      ALTER TABLE referral_reports
        ADD CONSTRAINT referral_reports_send_to_health_center_id_fk
        FOREIGN KEY (send_to_health_center_id)
        REFERENCES places(id)
    SQL
    
  end

  def self.down
    execute "ALTER TABLE referral_reports DROP FOREIGN KEY referral_reports_sender_id_fk"
    execute "ALTER TABLE referral_reports DROP FOREIGN KEY referral_reports_confirm_from_id_fk"
    execute "ALTER TABLE referral_reports DROP FOREIGN KEY referral_reports_place_id_fk"
    execute "ALTER TABLE referral_reports DROP FOREIGN KEY referral_reports_send_to_health_center_id_fk"
  end
  
end
