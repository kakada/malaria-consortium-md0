class TestController < ApplicationController
  def index
    Place
    place_classes = [Province, OD, HealthCenter, Village]
    users = User.includes(:place => [:parent => [:parent => :parent]]).where('place_id IS NOT NULL').all
    provinces = users.map {|x| x.place.get_parent(Province)}.uniq.reject{|x| x.nil?}
    ods = users.map {|x| x.place.get_parent(OD)}.uniq.reject{|x| x.nil?}
    hcs = users.map {|x| x.place.get_parent(HealthCenter)}.uniq.reject{|x| x.nil?}
    village = users.map {|x| x.place.get_parent(Village)}.uniq.reject{|x| x.nil?}

    @list = provinces
    ods.each {|x| @list.insert(@list.index x.parent + 1, x)}
    hcs.each {|x| @list.insert(@list.index x.parent + 1, x)}
    village.each {|x| @list.insert(@list.index x.parent + 1, x)}
    users.each {|x| @list.insert(@list.index x.place + 1, x)}

    @list.map! do |x|
      if x.is_a? User
        ["#{'=' * (place_classes.index(x.place.class) + 1)} #{x.user_name} (#{x.phone_number})", "sms://#{x.phone_number}"]
      else
        ["#{'-' * place_classes.index(x.class)} #{x.description}", nil]
      end
    end
  end

  def submit
    @result = Report.process(params[:report])
  end
end
