module Referal 
  class ReportsController < ReferalController
    def index
      page = (params[:page] || '1').to_i
      
      @reports = Referal::Report
      if(!params[:type].blank? )
         if params[:type] == "ClinicReport"
           @reports = ClinicReport
         elsif params[:type] == "HealthCenterReport"   
           @reports = HCReport
         end
      else
        @reports = Referal::Report
      end 
      
      @reports =@reports.paginate :page => page, :per_page => PerPage
      
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
  end
end