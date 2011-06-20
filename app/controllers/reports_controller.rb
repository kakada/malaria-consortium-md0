class ReportsController < ApplicationController
  include ReportsConcern

  before_filter :set_tab
  before_filter :get_report, :only => [:edit, :update]

  def index
    @pagination = {
      :page => get_page,
      :per_page => 20
    }

    if params[:error] == 'last'
      @reports = @place.reports.last_error_per_sender_per_day
    else
      @reports = @place.reports
      @reports = @reports.order('id desc').includes(:sender, :village, :health_center)
      @reports = @reports.where(:error => true) if params[:error] == 'true'
    end
    @reports = @reports.paginate @pagination
  end

  def edit
    if @report.place.class == HealthCenter
      @od = @report.place.parent
    else
      @od = @report.place.parent.parent
    end
    @villages = @od.health_centers.includes(:villages).to_a.map do |health_center|
      [health_center.short_description, health_center.villages.to_a.map do |village|
        [village.short_description, village.id]
      end]
    end
    @villages.insert 0, ['', ['Select one...', '']]
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

  #GET report_form
  def report_form
    @tab = :reported_case
    @reports = []
    @reports = Report.report_cases_paginate params if params[:from].present?
  end

  #GET report_detail
  def report_detail
    @place = Place.find(params[:place_id])
    @reports = Report.no_error.at_place(@place).between_dates(params[:from], params[:to])
    @reports = @reports.paginate :page => get_page, :per_page => 20
    render :layout =>false
  end

  # GET reports/report_csv
  def report_csv
    file = Report.write_csv(params)
    file = File.open(file, "rb")
    contents = file.read
    send_data contents, :type => "text/csv" , :filename => Report.report_file(params[:place_type],params[:from],params[:to])
  end

  def generated_messages
    @report = Report.find(params[:id])
    @messages = @report.generated_messages
    render :layout => false
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
