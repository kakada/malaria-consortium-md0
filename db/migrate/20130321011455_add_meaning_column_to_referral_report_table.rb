class AddMeaningColumnToReferralReportTable < ActiveRecord::Migration
  def self.up
    add_column :referral_reports  , :meaning1, :string
    add_column :referral_reports  , :meaning2, :string
    add_column :referral_reports  , :meaning3, :string
    add_column :referral_reports  , :meaning4, :string
    add_column :referral_reports  , :meaning5, :string
  end

  def self.down
    remove_column :referral_reports  , :meaning1
    remove_column :referral_reports  , :meaning2
    remove_column :referral_reports  , :meaning3
    remove_column :referral_reports  , :meaning4
    remove_column :referral_reports  , :meaning5
  end
end
