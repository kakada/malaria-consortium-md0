class CreateAlertPfNotifications < ActiveRecord::Migration
  def self.up
    create_table :alert_pf_notifications do |t|
      t.integer :user_id
      t.integer :report_id
      t.date :send_date
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :alert_pf_notifications
  end
end
