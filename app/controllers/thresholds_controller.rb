class ThresholdsController < ApplicationController
  Place

  def index
    @provinces = Province.includes(:ods).all
    selected_od_id = (params[:od_id] || @provinces.first.ods.first.id).to_i
    @od = OD.includes(:health_centers).find(selected_od_id)
    selected_hc_id = (params[:hc_id] || @od.health_centers.first.id).to_i
    @villages = Village.find_all_by_parent_id(selected_hc_id)

    if params[:commit]
      params[:threshold].each do |k, v|
        case k
        when 'hc'
          set_threshold_value 'HealthCenter', selected_hc_id, v
        when 'village_default'
          set_threshold_value 'Village', selected_hc_id, v
        else
          set_threshold_value 'Village', k.to_i, v
        end
      end
    end

    @thresholds = {}
    Threshold.where(:place_id => @villages.map(&:id) + [selected_hc_id]).each do |th|
      if th.place_class == HealthCenter.name
        @thresholds['hc'] = th.value
      elsif th.place_id == selected_hc_id
        @thresholds['village_default'] = th.value
      else
        @thresholds[th.place_id] = th.value
      end
    end
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

end