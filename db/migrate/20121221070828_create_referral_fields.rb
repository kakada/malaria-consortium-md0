class CreateReferralFields < ActiveRecord::Migration
  def self.up
    create_table :referral_fields do |t|
      t.string   :name
      t.string   :meaning
      t.string   :template
      t.integer  :position
      t.timestamps
    end
  end

  def self.down
    drop_table :referral_fields
  end
end
