class CreateConstraintTable < ActiveRecord::Migration
  def self.up
    create_table :referal_constraints do |t|
      t.text       :validator
      t.references :field
      t.timestamps
    end
  end

  def self.down
    drop_table :referal_constraints
  end
end
