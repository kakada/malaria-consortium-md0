module Referal
  module ConstraintType
    class Min < Validator
      attr_accessor :min
      def message
        "{field}: {value} should be greater than or equal to {min}"
      end

      def template
        { :field  => @field.humanize,
          :value  => @value,
          :min    => @min
        }
      end

      def initialize(min)  
        @min        =  min
        @errors  = [] 
      end

      def validate value, field
        @value   = value.to_f
        @field   = field
        @errors     << translate_error if(@value < @min)
        @errors.size == 0 ? true : false
      end

      def to_s
        "Min(#{@min})"
      end
    end
  end
end