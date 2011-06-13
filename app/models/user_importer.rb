require 'csv'
class UserImporter < CSV

  def self.parse file
    users = []
    self.foreach(file, :headers => :first_row, :skip_blanks => true) do |row|
      attributes = {
         :user_name => row[0],
         :email => row[1],
         :phone_number => row[2],
         :password => row[3],
         :password_confirmation => row[3],
         :intended_place_code => row[4],
         :role => self.role(row[5])
      }
      user =  User.new attributes
      user.valid?
      users << user
    end
    users
  end

  def self.import file
    count = 0
    self.foreach(file,:headers => :first_row, :skip_blanks => true) do |row|
      attributes = {
         :user_name => row[0],
         :email => row[1],
         :phone_number => row[2],
         :password => row[3],
         :password_confirmation => row[3],
         :intended_place_code => row[4],
         :role => self.role(row[5])
      }
      user =  User.new attributes
      count +=1 if user.save
    end
    count
  end

  def self.role str
    User::Roles.include?(str) ?  str : "default"
  end
  
end