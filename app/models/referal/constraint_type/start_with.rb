module Referal
  module ConstraintType
  class StartWith < Validator
      attr_accessor :start
      def message
        '{field}: {value} should start with {start}'
      end

      def template
        { :field  => @field.humanize,
          :value  => @value,
          :start  => @start
        }
      end

      def initialize start
        @start = start
        @errors  = [] 
      end

      def validate value, field 
        @value   = value
        @field   = field
        start_with = Regexp.escape(@start)
        reg_start_with = Regexp.new(start_with, true)   
        @errors     << translate_error if(!@value.index(reg_start_with))
        @errors.size == 0 ? true : false
      end
      
      def to_s
        "StartWith(#{@start})"
      end
  end
  end
end