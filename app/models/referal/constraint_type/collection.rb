module Referal
  module ConstraintType
  class Collection < Validator
    attr_accessor :collection
    
    def message
        "{field}: {value} should be in collection ({collection})"
      end

      def template
        { :field  => @field.humanize,
          :value  => @value,
          :collection => @collection
        }
      end

      def initialize collection
        @collection  =  collection   
        @errors  = [] 
      end

      def validate value, field
        @value      = value.to_s
        @field      = field
        found = false
        @collection.split(",").each do |condition|
          
          condition_reg_str = Regexp.escape(condition)
          condition_reg = Regexp.new("^" + condition_reg_str + "$", true) 
          if(condition_reg.match(@value))
            found = true
            break
          end
        end
        
        @errors     << translate_error if !found
        @errors.size == 0 ? true : false
      end
      
      def to_s
        @collection = @collection || []
        "Collection(#{@collection})"
      end
  end
  end
end