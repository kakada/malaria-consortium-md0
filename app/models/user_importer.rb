require 'csv'
class UserImporter < CSV

  def self.simulate file
    users = []
    process_csv file do |user|
      user.valid?
      users << user
    end
    users
  end

  def self.import file
    count = 0
    process_csv file do |user|
      count += 1 if user.save
    end
    count
  end

  def self.process_csv(file)
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
      yield user
    end
  end

  def self.role str
    str.blank? ? "default" : str
  end
  
end