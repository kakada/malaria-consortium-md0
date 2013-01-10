module Referal
  class Field < ActiveRecord::Base
    set_table_name "referal_fields"
    has_many  :constraints, :class_name => "Referal::Constraint"
    validates :meaning ,  :template , :presence => true
    validates :meaning,   :uniqueness => true
    validates :name,  :uniqueness => true
    
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
    FixFieldClinic  = ["phone_number", "od", "book_number", "code_number", "slip_code", "health_center"]
    FixFieldHC      = ["phone_number", "od", "book_number", "code_number", "slip_code" ]
    
    
    before_validation :fill_data 
    after_destroy :clean_validator
    
    def clean_validator
      field = self.name;
      
      Referal::MessageFormat.all.each do |msg_format| 
         tags = msg_format.format.split(Referal::MessageFormat::Separator)
         result = []
         tags.each do |tag|
           result << tag  if tag != "{#{field}}"
         end
         msg_format.format = result.join(Referal::MessageFormat::Separator) 
         msg_format.save
      end
      
    end
    
    def position_chosen
       "Field already chosen"
    end
    
    def self.tags_hc
      self.tags FixFieldHC
    end
    
    def self.tags_clinic
       self.tags FixFieldClinic
    end
   
    def self.tags tag_fields
      name_list = self.all.map{|field| field.name}
      return tag_fields + name_list
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
      self::FieldName + "#{i}"
    end
    
  end
end