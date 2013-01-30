class CreateConstraintTable < ActiveRecord::Migration
  def self.up
    create_table :referral_constraints do |t|
      t.text       :validator
      t.references :field
      t.timestamps
    end
  end

  def self.down
    drop_table :referral_constraints
  end
end
