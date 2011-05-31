class AddIndicesToUsers < ActiveRecord::Migration
  Types = :country, :province, :od, :health_center, :village

  def self.up
    Types.each do |type|
      add_index :users, ["#{type}_id", :place_class]
    end
    add_index :users, :place_id
    add_index :users, [:last_report_error, :updated_at]
  end

  def self.down
    Types.each do |type|
      remove_index :users, ["#{type}_id", :place_class]
    end
    remove_index :users, :place_id
    remove_index :users, [:last_report_error, :updated_at]
  end
end
