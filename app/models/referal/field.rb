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
    FixField= ["phone_number", "od", "book_number", "code_number", "slip_code", "health_center"]
    
    before_save :fill_data    
   
    def self.tags
      name_list = self.all.map{|field| field.name}
      return self::FixField + name_list
    end
    
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