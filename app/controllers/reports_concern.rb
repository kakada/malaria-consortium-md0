module ReportsConcern
  extend ActiveSupport::Concern

  included do
    before_filter :get_places
    before_filter :build_breadcrumb
    before_filter :get_users
  end

  module InstanceMethods
    def get_places
      @place = Place.find params[:place] if params[:place]
      if @place
        @places = @place.sub_places.order(:name).all
      else
        @places = Province.order(:name).all
      end
    end

    def build_breadcrumb
      @breadcrumb = []
      if @place
        @breadcrumb.insert 0, :label => @place.name
        parent = @place
        while parent = parent.parent
          @breadcrumb.insert 0, :label => parent.name, :place => parent
        end
        @breadcrumb.insert 0, :label => 'All provinces', :place => 0
      else
        @breadcrumb.insert 0, :label => 'All provinces'
      end
    end

    def get_users
      @users = []
      if @place
        @users.push :place => @place.class, :users => @place.users

        options = {}
        options.send(:[]=, "#{@place.class.to_s.tableize.singularize}_id", @place.id)
        types = Place::Types.from(Place::Types.index(@place.class.to_s) + 1).each do |type|
          options[:place_class] = type
          @users.push :place => type.constantize, :count => User.where(options).count
        end
      else
        Place::Types.from(1).each do |type|
          @users.push :place => type.constantize, :count => User.where(:place_class => type).count
        end
      end
    end
  end

  module ClassMethods
  end
end
