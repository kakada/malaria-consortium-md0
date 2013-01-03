class CreateReferalFields < ActiveRecord::Migration
  def self.up
    create_table :referal_fields do |t|
      t.string   :name
      t.string   :meaning
      t.string   :template
      t.integer  :position
      t.timestamps
    end
  end

  def self.down
    drop_table :referal_fields
  end
end
