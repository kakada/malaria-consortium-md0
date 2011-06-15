class MapVisualizationsController < ApplicationController
  include ReportsConcern

  before_filter :set_tab

  def index
    @place = Place.find params[:id]
    @reports = MapVisualization.paginate_report params.except(:action, :controller)
    render :layout => false
  end

  def map_report
    render :json => MapVisualization.report_case_count(params.except(:action, :controller))
  end

  def map_view
    @place_id = params[:place].to_i
    @place_id = Country.national.id if @place_id == 0
  end

  def pushpin
    pushpin = Pushpin.new 100, 20
    send_data pushpin.image(params).to_blob, :disposition => 'inline', :type => Pushpin.type
  end

  def set_tab
    @tab = :map
  end

end
