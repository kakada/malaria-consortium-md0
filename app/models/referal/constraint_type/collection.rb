module Referal
  module ConstraintType
  class Collection < Validator
    attr_accessor :collection
    
    def message
        "{field}: {value} should be between [{collection}]"
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
        @errors     << translate_error if(! @collection.include? @value)
        @errors.size == 0 ? true : false
      end
      
      def to_s
        @collection = @collection || []
        "Collection(#{@collection})"
      end
  end
  end
end