class ReportsController < ApplicationController
  include ReportsConcern

  def index
    @pagination = {
      :page => params[:page] || 1,
      :per_page => 10
    }
    if @place
      @reports = @place.reports
    else
      @reports = Report
    end
    @reports = @reports.order('id desc').includes(:sender, :village, :health_center).paginate @pagination
  end
end
