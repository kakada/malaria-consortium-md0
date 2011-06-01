# encoding: utf-8
class ReportsController < ApplicationController
  include ReportsConcern

  before_filter :set_tab
  before_filter :get_report, :only => [:edit, :update]

  def index
    @pagination = {
      :page => params[:page].presence || 1,
      :per_page => 10
    }

    if params[:error] == 'last'
      @reports = User.order('updated_at desc').where(:last_report_error => true).includes(:last_report).paginate @pagination
    else
      @reports = @place.reports
      @reports = @reports.order('id desc').includes(:sender, :village, :health_center)
      @reports = @reports.where(:error => true) if params[:error] == 'true'
      @reports = @reports.paginate @pagination
    end
  end

  def edit
    if @report.place.class == HealthCenter
      @villages = Village.where(:parent_id => @report.place_id)
    else
      @villages = Village.where(:parent_id => @report.place.parent_id)
    end
    @villages = @villages.map { |v| [v.short_description, v.id] }
    @villages.insert 0, ['Select one...', '']
  end

  def update
    @report.update_attributes params[:report].slice(:sex, :age, :malaria_type, :village_id)
    @report.error = false
    if @report.save
      redirect_to reports_path(params.slice(:error, :place, :page)), :notice => 'Report edited successfully'
    else
      edit and render :edit
    end
  end


  def report_form
    @tab = :reported_case
    @places = []
    @per_page = 25
    @place = params[:place].present? ?  Place.find(params[:place]) : Country.first

    place_no_report = false
    
    if(params[:from].present?)

      
      page = params[:page]
      from = params[:from]
      to = params[:to]
      @type = params[:place_type]
      
      place_type_id = "#{@place.class.to_s.tableize.singularize}_id"


  
      if(@type == "Village")
        query = Place.joins(" LEFT JOIN reports ON places.id = reports.village_id").
                     select('places.name, places.id, places.code, places.type, places.name_kh, count(*) as total').
                     where(["reports.#{place_type_id} = :place_type_id AND reports.created_at BETWEEN :from AND :to AND places.type = :type ",{
                        :from => from, :to => to, :place_type_id => @place.id , :type =>"Village" }]).group("places.id")
                  
        if(@place.type == "Village")
           query = query.where(["places.id = :id", {:id => @place.id}])
        end

        if(params[:ncase] == "0")
          query.where("reports.place_id IS NULL ")
        end

        


       elsif(@type == "HealthCenter")
         query = Place.joins(" LEFT JOIN reports ON places.id = reports.health_center_id").
                     select('places.name, places.id, places.code, places.type, places.name_kh, count(*) as total').
                     where(["reports.#{place_type_id} = :place_type_id AND reports.created_at BETWEEN :from AND :to AND places.type = :type ",{
                        :from => from, :to => to, :place_type_id => @place.id , :type =>"HealthCenter" }]).group("places.id")
                  
         if(params[:ncase] == "0")
            query.where("reports.place_id IS NULL ")
         end


       end

       @places = query.paginate :page => page,:per_page => @per_page , :order => " total desc, places.name "
      
    end
  end

  private

  def set_tab
    @tab = case params[:error]
    when 'true'
      :error_messages
    when 'last'
      :last_error_messages
    else
      :all_messages
    end
  end

  def get_report
    @report = Report.find params[:id]
  end
end
