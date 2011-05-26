module ReportsConcern
  extend ActiveSupport::Concern

  included do
    before_filter :get_places
    before_filter :build_breadcrumb
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
  end

  module ClassMethods
  end
end
