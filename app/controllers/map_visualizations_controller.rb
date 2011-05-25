class MapVisualizationsController < ApplicationController
  
  def index
    @id = params[:id]
    from = params[:from]
    to = params[:to]
    
    page = params[:page]
    @reports = MapVisualization.paginate_report(@id, to, from, page)

    render :layout =>false
  end

  def map_report
    from = params[:from]
    to = params[:to]
    id = params[:id]

    @result = MapVisualization.report_case_count(id, from, to)
    render :json =>@result
  end
  
  def map_view
    @country = Place.find_by_type "Country"
  end
  
end