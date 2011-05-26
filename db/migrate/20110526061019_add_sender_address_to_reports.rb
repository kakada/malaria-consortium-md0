class AddSenderAddressToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :sender_address, :string
  end

  def self.down
    remove_column :reports, :sender_address
  end
end
