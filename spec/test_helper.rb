module Helpers
  def od name , id = nil
    OD.create! :name => name, :name_kh => name, :code => name, :parent_id => id
  end

  def province name
    Province.create! :name => name, :name_kh => name, :code => name
  end

  def user attribs
    User.create! attribs
  end

  def national_user number
    User.create! :phone_number => number, :role => "national"
  end

  def admin_user number
    User.create! :phone_number => number, :role => "admin"
  end

  def assert_parse_error body, error_message
    @parser.parse body
    @parser.errors?().should == true
    @parser.error.should == @parser.class.send(error_message, body)
    @parser.report.error_message == error_message.to_s.gsub('_', ' ')
  end

  def import_places
    place_import = PlaceImporter.new(File.join("models","test.csv"))
    place_import.import

    #report_format
    villages = [ [2010410, 3 ] ,
                 [2010405, 3 ] ,
                 [2010203, 3 ] ,
                 [2010406, 3 ] ,
                 [2010407, 3 ] ,
                 [2010305, 3 ] ,
                 [2010202, 3 ] ,
                 [2010409, 3 ] ,
                 [2010206, 3 ] ,
                 [2010402, 3 ] ,
                 [2010205, 3 ] ,
                 [2010204, 3 ] ,
                 [2010105, 3 ] ,
                 [2010302, 3 ] ,
                 [2010401, 3 ] ,
                 [2010403, 3 ] ,
                 [2010303, 3 ] ,
                 [2010404, 3 ] ,
                 [2010304, 3 ] ,
                 [2010207, 3 ] ,
                 [2010201, 3 ] ,
                 [2010308, 3 ] ,
                 [2010106, 3 ] ,
                 [2010307, 3 ] ,
                 [2010104, 3 ] ,
                 [2010408, 3 ] ,
                 [2010103, 3 ] ,
                 [2010306, 3 ] ,
                 [2010101, 3 ] ,
                 [2010301, 3 ] ,
                 [2010102, 3 ] ,
                 [2010107, 3 ] ,
                 [1100210, 3 ] ,
                 [1100111, 3 ] ,
                 [1100202, 3 ] ,
                 [1100201, 3 ] ,
                 [1100203, 3 ] ,
                 [1100113, 3 ] ,
                 [1100112, 3 ] ,
                 [1100207, 3 ] ,
                 [1100206, 3 ] ,
                 [1100208, 3 ] ,
                 [1100205, 3 ] ,
                 [1100114, 3 ] ,
                 [1100115, 3 ] ,
                 [1100116, 3 ] ,
                 [1070117, 3 ] ,
                 [1100211, 3 ] ,
                 [1100110, 3 ] ,
                 [1100204, 3 ] ,
                 [1100209, 3 ]
                ]
  end
end
