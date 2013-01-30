module Referral
  class Constraint <  ActiveRecord::Base
    set_table_name "referral_constraints"
    belongs_to :field, :class_name => "Referral::Field"
    serialize :validator
  end
end