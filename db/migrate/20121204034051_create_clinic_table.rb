class CreateClinicTable < ActiveRecord::Migration
  def self.up
    create_table :clinics do |t|
      t.string  :od_name
      t.string  :book_number
      t.integer :code_number
      t.string  :patient_phone
      t.string  :slip_code
      t.integer :status
      t.boolean :valid, :default => true
      
      t.string  :nuntium_token
      t.text       :message   
      
      t.references :confirm_from  
      t.references :sender
      t.references :place
      t.references :province
      t.references :country
      t.timestamps
    end                 
  end

  def self.down   
    drop_table :clinics
  end
end
