class ReportsController < ApplicationController
  include ReportsConcern

  def index
    @tab = :all_messages

    @pagination = {
      :page => params[:page] || 1,
      :per_page => 10
    }
    if @place
      @reports = @place.reports
    else
      @reports = Report
    end
    @reports = @reports.order('id desc').includes(:sender, :village, :health_center)
    if params[:error]
      @reports = @reports.where(:error => true)
      @tab = :error_messages
    end
    @reports = @reports.paginate @pagination
  end
end
