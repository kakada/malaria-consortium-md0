module ReportsConcern
  extend ActiveSupport::Concern

  included do
    before_filter :get_places
    before_filter :build_breadcrumb
    before_filter :get_users
  end

  module InstanceMethods
    def get_places
      if params[:place].present?
        @place = Place.find_by_id params[:place]
      elsif params[:place_search].present?
        @place = Place.find_by_code params[:place_search]
        if @place
          params[:place] = @place.id
        end
      end
      @place = Country.national unless @place
      @navbar_places = @place.sub_places.order(:name).all
    end

    def build_breadcrumb
      @breadcrumb = []
      @breadcrumb.insert 0, :label => @place.name
      parent = @place
      while parent = parent.parent
        @breadcrumb.insert 0, :label => parent.name, :place => parent
      end
    end

    def get_users
      @users = User.count_user @place
    end
  end

  module ClassMethods
  end
end
