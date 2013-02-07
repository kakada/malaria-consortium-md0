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
    
    def index
      report_type 
      @reports =@reports.paginate :page => @page, :per_page => PerPage
    end
    
    def error
      report_type 
      @reports = @reports.error
      @reports =@reports.paginate :page => @page, :per_page => PerPage
    end
    
    def ignored
      report_type 
      @reports = @reports.ignored
      @reports =@reports.paginate :page => @page, :per_page => PerPage
    end
    
    def search
      @reports = Referral::Report.not_ignored
      
      if(!params[:before].blank?)
        @reports = @reports.since(params[:before])
      end
      
      if(!params[:query].blank?)
        @reports = @reports.query(params[:query])
      end
      
      
      
      @reports =@reports.paginate :page => @page, :per_page => PerPage
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
    
    def duplicated
      @reports = Referral::Report.duplicated_per_sender
      @reports =@reports.paginate :page => @page, :per_page => PerPage
    end
    
    
    def toggle
      begin
        report = Referral::Report.find(params[:id])
        report.ignored = ! report.ignored
        report.save
        msg = "Report has been ignored"
      rescue
        msg = "Failed to ignore report. Try it again"
      end
      flash[:notice] = msg
      redirect_to referral_reports_path(params.slice(:type))
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