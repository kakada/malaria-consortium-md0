module Referral
  module ConstraintType
      class Between < Validator
        attr_accessor :from, :to
        def message
            "{field}: {value} should be between {from}, {to}"
          end

          def template
            { :field  => @field.humanize,
              :value  => @value,
              :from   => @from,
              :to     => @to
            }
          end

          def initialize from, to
            @from        =  from
            @to          =  to
            @errors  = [] 
          end

          def validate value, field      
            @value   = value
            @field   = field
            @errors     << translate_error if(@value.to_f > @to.to_f || @value.to_f < @from.to_f)
            @errors.size == 0 ? true : false
          end

          def to_s
            "Between(from = #{@from},  to = #{@to} )"
          end
      end
  end
end
