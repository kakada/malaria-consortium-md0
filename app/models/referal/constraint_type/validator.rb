module Referal
  module ConstraintType
    class Validator
      attr_accessor :errors, :value

      Options = [
        ["Select a validation"],
        ["Between" ],
        ["Collection"], 
        ["DifferenceFrom"],
        ["EqualTo"],
        ["Length"],
        ["Max"],
        ["Min"],
        ["StartWith"]
      ]

      def template
        raise "You must define template method for error message"
      end

      def message
        raise "You must define message method for template"
      end

      def validate
        raise "You must define validate method"
      end

      def translate_error
        message.apply(template)
      end

      def self.get_validator(name, *args)
        case name
        when "Between"
          Referal::ConstraintType::Between.new(*args)
        when "Collection"
          Referal::ConstraintType::Collection.new(*args)
        when "DifferenceFrom"
          Referal::ConstraintType::DifferenceFrom.new(*args)
        when "EqualTo"
          Referal::ConstraintType::EqualTo.new(*args)
        when "Length"
          Referal::ConstraintType::Length.new(*args)
        when "Max"
          Referal::ConstraintType::Max.new(*args)
        when "Min"
          Referal::ConstraintType::Min.new(*args)
        when "StartWith"
          Referal::ConstraintType::StartWith.new(*args)
        else  
          nil
        end
      end
      
      
      
    end
  end
  
end
