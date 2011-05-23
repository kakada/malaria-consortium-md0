class AddTypeToAlert < ActiveRecord::Migration
  class Alert < ActiveRecord::Base; end

  def self.up
    add_column :alerts, :type, :string
    Alert.update_all("type = CONCAT(source_type, 'Alert')")
  end

  def self.down
    remove_column :alerts, :type
  end
end
