module Referal
  class Field < ActiveRecord::Base
    set_table_name "referal_fields"
    has_many :constraints, :class_name => "Referal::Constraint"
    validates :meaning , :template , :presence => true
    validates :meaning, :uniqueness => true
    
    FieldName = "Field"
    Constraint = [
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
    
    before_save :fill_data    
   
    
    def self.fields_set_exist(fields, pos)
      fields.each do |field|
        if field.position == pos
          return field
        end
      end
      return nil
    end
    
    def fill_data
      self.name = Referal::Field.columnize(self.position)
    end
   
    
    def self.columnize i
      self::FieldName + " #{i}"
    end
    
  end
end