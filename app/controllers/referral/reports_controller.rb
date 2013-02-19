module Referral 
  class ReportsController < ReferralController
    
    before_filter :set_default_page
    
    def set_default_page
      @page = (params[:page] || '1').to_i
    end
    
    def report_type
      if(!params[:type].blank? )
         if params[:type] == "ClinicReport"
           @reports = ClinicReport
         elsif params[:type] == "HealthCenterReport"   
           @reports = HCReport
         end
      else
        @reports = Referral::Report
      end 
    end
    
    def valid
      report_type 
      @reports = @reports.includes(:confirm_from).no_error.not_ignored
      
      respond_to do |format|
        format.html { @reports = @reports.paginate :page => @page, :per_page => PerPage }
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
    end
      
    def index
      report_type 
      @reports = @reports.includes(:confirm_from)
      respond_to do |format|
        format.html { @reports = @reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :json => @reports.as_csv }
        format.json { render :json => @reports }
      end
    end
    
    def error
      report_type 
      @reports = @reports.includes(:confirm_from).error
      respond_to do |format|
        format.html { @reports =@reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
    end
    
    def ignored
      report_type 
      @reports = @reports.includes(:confirm_from).ignored
      respond_to do |format|
        format.html { @reports =@reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
    end
    
    def search
      @reports = Referral::Report.includes(:confirm_from).not_ignored
      
      @reports = @reports.between(params[:from], params[:to])
     
      
      if(!params[:query].blank?)
        @reports = @reports.query(params[:query])
      end
      
      respond_to do |format|
        format.html { @reports = @reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
    end
    
    def confirmed
      @reports = Referral::ClinicReport.includes(:confirm_from).confirmed
      respond_to do |format|
        format.html { @reports =@reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
      
    end
    
    def not_confirmed
      @reports = Referral::ClinicReport.includes(:confirm_from).not_confirmed
      respond_to do |format|
        format.html { @reports =@reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
      
    end
    
    def duplicated
      @reports = Referral::Report.includes(:confirm_from).duplicated_per_sender
      respond_to do |format|
        format.html { @reports = @reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
    end
    
    def edit 
      url = request.env["HTTP_REFERER"]
      session[:from_uri] = url
      @report = Referral::Report.find params[:id]
    end
    
    def update
      @report = Referral::Report.find(params[:id])
      attr_key   = ActiveModel::Naming.singular(@report)
      attrs = params[attr_key]
      if @report.update_attributes(attrs)
        flash[:notice] = "Report has been updated"
        redirect_to session[:from_uri]
      else
        flash.now[:notice] = "Report failed to update"
        render :edit
      end
    end
    
    def simulate
      @from = params[:from]
      @body = params[:body]
      @guid = params[:guid]
      
      if( request.post?)
        message_proxy = MessageProxy.new(:from => @from, :body => @body, :guid => @guid)
        @messages = message_proxy.process
        @messages = [@messages] if @messages.class != Array
        @report   = message_proxy.report 
        
        if(@report)
          @report.ignored =true
          @report.save
        end
      end
    end
    
    def toggle
      begin
        report = Referral::Report.find(params[:id])
        report.ignored = !report.ignored
        report.save!
        msg = "Report has been ignored"
      rescue 
        msg = "Failed to ignore report. Try it again"
      end
      flash[:notice] = msg
      redirect_to request.env["HTTP_REFERER"]
    end
    
    def destroy
      begin
        report = Referral::Report.find(params[:id])
        report.destroy
        flash[:notice] = "Report has been deleted"
      rescue
        flash[:error] = "Failed to delete report. Try it again"
      end
      
      url = request.env["HTTP_REFERER"]
      redirect_to url
    end
  end
end