module Referal
  module ConstraintType
  class DifferenceFrom < Validator
    attr_accessor :equal
    def message
       "{field}: {value} should be not be equal to {equal}"
    end
    
    def template
      { :field    => @field.humanize,
        :value    => @value,
        :equal    => @equal
      }
    end
    
    def initialize equal
      @equal      =  equal
      @errors  = [] 
    end
    
    def validate value, field      
      @value   = value
      @field   = field
      
      @errors     << translate_error if(@value == @equal)
      @errors.size == 0 ? true : false
    end
    
    def to_s
      "DifferentFrom(#{@equal})"
    end
  end
  end
end
