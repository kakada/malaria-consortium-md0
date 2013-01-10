module Referal
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
            @value   = value.to_f
            @field   = field
            @errors     << translate_error if(@value > @to || @value < @from)
            @errors.size == 0 ? true : false
          end

          def to_s
            "Between(from = #{@from},  to = #{@to} )"
          end
      end
  end
end
