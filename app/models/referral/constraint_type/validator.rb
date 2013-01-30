module Referral
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
          Referral::ConstraintType::Between.new(*args)
        when "Collection"
          Referral::ConstraintType::Collection.new(*args)
        when "DifferenceFrom"
          Referral::ConstraintType::DifferenceFrom.new(*args)
        when "EqualTo"
          Referral::ConstraintType::EqualTo.new(*args)
        when "Length"
          Referral::ConstraintType::Length.new(*args)
        when "Max"
          Referral::ConstraintType::Max.new(*args)
        when "Min"
          Referral::ConstraintType::Min.new(*args)
        when "StartWith"
          Referral::ConstraintType::StartWith.new(*args)
        else  
          nil
        end
      end
      
      
      
    end
  end
  
end
