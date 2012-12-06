# encoding: UTF-8

class Clinic < ActiveRecord::Base
  
  has_many :replies
  belongs_to :confirm_from, :class_name => "HealthCenter"
  
  belongs_to :send_to_health_center, :class_name => "HealthCenter"
  belongs_to :sender,  :class_name => "User"
  belongs_to :place
  belongs_to :od, :class_name => "OD"
  belongs_to :province, :class_name => "Province"
  belongs_to :country, :class_name => "Country"
  
  
  
  def create_error_record params
     
      t.string     :od_name
      t.string     :book_number
      t.integer    :code_number
      t.string     :slip_code
      t.boolean    :valid, :default => true
      t.string     :nuntium_token
      t.text       :message
      
      t.boolean :ignored, :default => false
      t.boolean :error ,  :default => false
      t.string  :error_message
      
      t.references :clinic
      t.references :sender
      t.references :place
      t.references :od
      t.references :province
      t.references :country 
  end
  
end

