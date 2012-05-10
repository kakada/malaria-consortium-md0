class AddTokenToAlertPfNotification < ActiveRecord::Migration
  def self.up
    add_column :alert_pf_notifications, :token, :string
  end

  def self.down
    remove_column :alert_pf_notifications, :token
  end
end
