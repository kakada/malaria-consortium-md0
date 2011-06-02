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
    @place = params[:place].present? ?  Place.find(params[:place]) : Country.first
    @reports = Report.report_cases @place, params if params[:from].present?
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
