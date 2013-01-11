module Referal
  module ConstraintType
  class EqualTo < Validator
    attr_accessor :equal, :value
    
    def message
       "{field}: {value} should be equal to {equal}"
    end
    
    def template
      { :field    => @field.humanize,
        :value    => @value,
        :equal    => @equal
      }
    end
    
    def initialize equal
      @equal   =  equal
      @errors  = [] 
    end
    
    def validate value, field      
      @value   = value
      @field   = field
      @errors     << translate_error if(@value.to_s != @equal.to_s)
      @errors.size == 0 ? true : false
    end
    
    def to_s
      "EqualTo(#{@equal})"
    end
  end
  end
end
