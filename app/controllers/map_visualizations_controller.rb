class MapVisualizationsController < ApplicationController
  include ReportsConcern
  
  before_filter :set_tab

  def index
    @id = params[:id]
    attr = { :id => params[:id], :from => params[:from],
             :to => params[:to] ,:type => params[:type], :page => params[:page]
    }

    @reports = MapVisualization.paginate_report(attr)
    render :layout =>false
  end

  def map_report
    attr = { :id => params[:id], :from => params[:from], :to => params[:to] ,
            :type => params[:type] }
    
    result = MapVisualization.report_case_count(attr)
    render :json => result
  end
  
  def map_view
    @place_id = params[:place].to_i
  end

  def set_tab
    @tab = params[:error] == 'true' ? :error_messages : :map
  end
  
end