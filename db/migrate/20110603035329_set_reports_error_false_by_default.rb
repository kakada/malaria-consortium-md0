class SetReportsErrorFalseByDefault < ActiveRecord::Migration
  def self.up
    change_column :reports, :error, :boolean, :default => false
    ActiveRecord::Base.connection.execute('update reports set error = 0 where error is null')
  end

  def self.down
    change_column :reports, :error, :boolean
  end
end
