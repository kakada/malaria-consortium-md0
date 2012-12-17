class CreateReferalReportTable < ActiveRecord::Migration
  def self.up
    create_table :referal_reports do |t|
      t.string  :od_name
      t.string  :book_number
      t.string :code_number
      t.string  :phone_number
      t.string  :slip_code
      t.string  :health_center_code
      t.integer :status  
      t.string  :nuntium_token
      t.string  :text 
      t.string  :sender_address
      t.boolean :ignored, :default => false
      t.boolean :error ,  :default =>  false
      t.string  :error_message
      
      t.string  :type
      
      t.references :send_to_health_center
      t.references :confirm_from  
      t.references :sender
      t.references :place
      t.references :od
      t.references :province
      t.references :country
      t.references :reply_to
      t.timestamps
    end                 
  end

  def self.down   
    drop_table :referal_reports
  end
end
