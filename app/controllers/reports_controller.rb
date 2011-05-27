class ReportsController < ApplicationController
  include ReportsConcern

  def index
    @pagination = {
      :page => params[:page] || 1,
      :per_page => 10
    }
    @reports = Report.order('id desc').all.paginate @pagination
  end
end
