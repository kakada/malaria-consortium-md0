class ReportsController < ApplicationController
  include ReportsConcern

  before_filter :set_tab
  before_filter :get_report, :only => [:edit, :update]

  def index
    @pagination = {
      :page => params[:page].presence || 1,
      :per_page => 10
    }
    if @place
      @reports = @place.reports
    else
      @reports = Report
    end
    @reports = @reports.order('id desc').includes(:sender, :village, :health_center)
    @reports = @reports.where(:error => true) if params[:error] == 'true'
    @reports = @reports.paginate @pagination
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

  private

  def set_tab
    @tab = params[:error] == 'true' ? :error_messages : :all_messages
  end

  def get_report
    @report = Report.find params[:id]
  end
end
