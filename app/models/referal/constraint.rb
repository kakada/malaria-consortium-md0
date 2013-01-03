module Referal
  class Constraint <  ActiveRecord::Base
    set_table_name "referal_constraints"
    belongs_to :field, :class_name => "Referal::Field"
    serialize :validator
  end
end