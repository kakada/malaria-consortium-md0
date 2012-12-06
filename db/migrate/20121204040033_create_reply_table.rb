class CreateReplyTable < ActiveRecord::Migration
  def self.up
    create_table :replies do |t|
      t.string     :od_name
      t.string     :book_number
      t.integer    :code_number
      t.string     :slip_code
      t.boolean    :valid, :default => true
      t.string     :nuntium_token
      t.string  :sender_address
      t.string       :text
      t.boolean :ignored, :default => false
      t.boolean :error ,  :default => false
      t.string  :error_message
      
      t.references :clinic
      t.references :sender
      t.references :place
      t.references :od
      t.references :province
      t.references :country  
      t.timestamps
      
    end
  end

  def self.down
    drop_table :replies
  end
end