module Referral 
  class ReportsController < ReferralController
    def index
      page = (params[:page] || '1').to_i
      
      @reports = Referral::Report
      
      if(!params[:type].blank? )
         if params[:type] == "ClinicReport"
           @reports = ClinicReport
         elsif params[:type] == "HealthCenterReport"   
           @reports = HCReport
         end
      else
        @reports = Referral::Report
      end 
      
      if(params[:ignored].blank?)
        @reports = @reports.not_ignored
      else
        @reports = @reports.ignored
      end
      
      @reports =@reports.paginate :page => page, :per_page => PerPage
      
    end
    
    def edit 
      @report = Referral::Report.find params[:id]
    end
    
    def update
      @report = Referral::Report.find(params[:id])
      attr_key   = ActiveModel::Naming.singular(@report)
      attrs = params[attr_key]
      if @report.update_attributes(attrs)
        flash[:notice] = "Report has been updated"
        redirect_to referral_reports_path(:t => params[:t])
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
      page = (params[:page] || '1').to_i
      @reports = Referral::Report.duplicated_per_sender
      @reports =@reports.paginate :page => page, :per_page => PerPage
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
      redirect_to referral_reports_path(params.slice(:type, :ignored, :t))
    end
    
    def destroy
      begin
        report = Referral::Report.find(params[:id])
        report.destroy
        flash[:notice] = "Report has been deleted"
      rescue
        flash[:error] = "Failed to delete report. Try it again"
      end
      redirect_to referral_reports_path(params.slice(:type, :ignored, :t))
    end
  end
end