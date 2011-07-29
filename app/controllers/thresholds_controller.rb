class ThresholdsController < ApplicationController
  Place
  before_filter :get_threshold
  before_filter :augment_threshold

  def index
    @provinces = Province.includes(:ods).all
    
    if params[:od_id].present?
      @od ||= OD.find(params[:od_id])
    end
    @thresholds = Threshold.order("updated_at DESC").includes(:place => [:parent => :parent])

    if @od
      @health_centers = HealthCenter.includes(:villages).where(:parent_id => @od.id).order(:name)
      @thresholds = @thresholds.where('place_hierarchy LIKE ? OR place_hierarchy = ?', "#{@od.hierarchy}.%", @od.hierarchy)
    end
    render 'index'
  end

  def show
    @od = @threshold.place.get_parent(OD)
    return index
  end

  def create
    place_class, place_id = params[:threshold][:place_code].split(':')
    threshold = Threshold.create! :place_id => place_id, :place_class => place_class, :value => params[:threshold][:value]
    redirect_to :action => :index #, :od_id => threshold.place.get_parent(OD).id
  end

  def update
    threshold = Threshold.find params[:id]
    threshold.update_attributes :value => params[:threshold][:value]
    redirect_to :action => :index, :od_id => threshold.place.get_parent(OD).id
  end

  def destroy
    threshold = Threshold.find params[:id]
    threshold.destroy
    redirect_to :back
  end

  private

  def set_threshold_value place_class, place_id, value
    if value.present? && value.to_i > 0
      th = Threshold.find_or_create_by_place_class_and_place_id place_class, place_id
      th.value = value.to_i
      th.save!
    else
      Threshold.delete_all :place_class => place_class, :place_id => place_id
    end
  end

  def get_threshold
    @threshold = Threshold.find params[:id] if params[:id]
    if params[:threshold].try(:[], :place_code)
      place_class, place_id = params[:threshold][:place_code].split(':')
      @threshold = Threshold.find_by_place_id_and_place_class place_id, place_class
      @threshold ||= Threshold.new :place_id => place_id, :place_class => place_class
    end
    @threshold ||= Threshold.new

    if @threshold.place_id
      @od = @threshold.place.get_parent(OD)
    end
  end

  def augment_threshold
    class << @threshold
      def place_code
        "#{self.place_class}:#{place_id}" if place_class
      end
    end
  end

end
