class AddMessageToAlertPfNotification < ActiveRecord::Migration
  def self.up
    add_column :alert_pf_notifications, :message, :string
  end

  def self.down
    remove_column :alert_pf_notifications, :message
  end
end
