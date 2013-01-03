module Referal
  module ConstraintType
  class Length < Validator
    attr_accessor :length, :value
    def message
       "{field}: {value} does not have length match to {length}"
    end
    
    def template
      {
        :field  => @field.humanize,
        :value  => @value,
        :length => @length
      }
    end
    
    def initialize length
      @length =  length
      @errors  = [] 
    end
    
    def validate value, field      
      @value   = value
      @field   = field
      @errors << translate_error if(@value.to_s.size != @length)
      @errors.size == 0 ? true : false
    end
    
    def to_s
      "Length(#{@length})"
    end
  end
  end
end
