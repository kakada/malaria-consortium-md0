module Referal
  module ConstraintType
  class Max < Validator
    attr_accessor :max
    def message
       "{field}: {value} should be less than or equal to {max}"
    end
    
    def template
      { :field  => @field.humanize,
        :value  => @value,
        :max    => @max
      }
    end
    
    def initialize(max)
      @errors  = [] 
      @max        =  max
    end
    
    def validate value, field      
      @value   = value
      @field   = field
      
      @errors     << translate_error if(@value.to_f > @max.to_f)
      @errors.size == 0 ? true : false
    end
    
    def to_s
      "Max(#{@max})"
    end
  end
  end
end