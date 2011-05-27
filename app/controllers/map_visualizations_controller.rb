class MapVisualizationsController < ApplicationController
  
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
    @country = Place.find_by_type "Country"
  end  
end