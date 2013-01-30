class AddFiveDynamicColumnInReferralReport < ActiveRecord::Migration
  def self.up
    add_column :referral_reports  , :field1, :string
    add_column :referral_reports  , :field2, :string
    add_column :referral_reports  , :field3, :string
    add_column :referral_reports  , :field4, :string
    add_column :referral_reports  , :field5, :string
  end

  def self.down
    remove_column :referral_reports  , :field1
    remove_column :referral_reports  , :field2
    remove_column :referral_reports  , :field3
    remove_column :referral_reports  , :field4
    remove_column :referral_reports  , :field5
  end
end
