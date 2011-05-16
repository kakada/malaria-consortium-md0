class CreateThresholds < ActiveRecord::Migration
  def self.up
    create_table :thresholds, :force => true do |t|
      t.string :place_class
      t.references :place
      t.integer :value
      t.timestamps
    end
  end

  def self.down
    drop_table :thresholds
  end
end