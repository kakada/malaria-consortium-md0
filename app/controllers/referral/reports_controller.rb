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
      @referral_title = "Valid Report"
      respond_to do |format|
        format.html { @reports = @reports.paginate :page => @page, :per_page => PerPage }
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
    end
      
    def index
      report_type 
      @reports = @reports.includes(:confirm_from).order("id desc")
      @referral_title = "Report List"
      
      respond_to do |format|
        format.html { @reports = @reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :json => @reports.as_csv }
        format.json { render :json => @reports }
      end
    end
    
    def error
      report_type 
      @reports = @reports.includes(:confirm_from).error
      @referral_title = "Error Report"
      respond_to do |format|
        format.html { @reports =@reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
    end
    
    def ignored
      report_type 
      @reports = @reports.includes(:confirm_from).ignored
      @referral_title = "Ignored Report"
      respond_to do |format|
        format.html { @reports =@reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
    end
    
    def search
      @reports = Referral::Report.includes(:confirm_from).not_ignored
      
      @reports = @reports.between(params[:from], params[:to])
      @referral_title = "Search report #{params[:query]}"
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
      @referral_title = "Confirmed Report"
      respond_to do |format|
        format.html { @reports =@reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
      
    end
    
    def not_confirmed
      @reports = Referral::ClinicReport.includes(:confirm_from).not_confirmed
      @referral_title = "Not-confirmed Report"
      respond_to do |format|
        format.html { @reports =@reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
      
    end
    
    def duplicated
      @reports = Referral::Report.includes(:confirm_from).duplicated_per_sender
      @referral_title = "Valid report Duplicated"
      respond_to do |format|
        format.html { @reports = @reports.paginate :page => @page, :per_page => PerPage}
        format.csv  { render :text => @reports.as_csv}
        format.json { render :json => @reports }
      end
    end
    
    def edit 
      url = request.env["HTTP_REFERER"]
      session[:from_uri] = url
      @referral_title = "Edit Report"
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
    
    def rectify
      @referral_title = "Retify Report"
      @report = Referral::Report.find params[:id]
      @from = @report.sender_address
      @body = @report.text
    end
    
    def apply
      @report = Referral::Report.find params[:id]
      @error = {:error => false, :message => "", :raw => ""}
      @from   = params[:from]
      @body   = params[:body]   
      
      message_proxy = MessageProxy.new(:from => @from, :body => @body, :guid => "")
      message_proxy.analyse_number
      if message_proxy.params[:error]
          @error = { :error => true, :message => message_proxy.params[:error_message]  }
      else
        if !message_proxy.params[:sender].is_from_referral?
          @error = { :error => true, :message =>  "Not register in referral system" }
        else
           @rectify_report = Referral::Report::decode message_proxy.params.dup
           if(@rectify_report.error)
             @error = { :error => true, 
                        :message =>  @rectify_report.translate_message_for(@rectify_report.error_message),
                        :raw => @rectify_report.error_message
                        }
           else
              _store_rectified_report
              _send_alert_to_other  
           end
        end
      end
      if(@error[:error])
          render :rectify
      else  
        flash["notice"] = "Report <b> #{@report.text} </b>has been rectified"
        redirect_to referral_reports_path
      end
    end
    
    def simulate
      @from = params[:from]
      @body = params[:body]
      @guid = params[:guid]
      @referral_title = "Simulate Report"
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
      @referral_title = "Ignore/UnIgnored Report"
      begin
        report = Referral::Report.find(params[:id])
        current = report.ignored
        report.ignored = !current
        report.save!
        msg = current ? "Report has been unignored" : "Report has been ignored"     
      rescue 
        msg = current ?  "Failed to unignore report. Try it again" : "Failed to ignore report. Try it again"
      end
      flash[:notice] = msg
      redirect_to request.env["HTTP_REFERER"]
    end
    
    def destroy
      begin
        report = Referral::Report.find(params[:id])
        report.destroy
        flash[:notice] = "Report has been deleted"
      rescue Exception => e
        flash[:error] = "Failed to delete report with error : " + e.message
      end
      
      url = request.env["HTTP_REFERER"]
      redirect_to url
    end
    
    def delete_all
      reports = Referral::Report.where(["id in (:reports)", :reports => params[:referral_report]]);
      count = 0
      reports.each do |report|
        begin
          report.destroy
          count = count +1
        rescue Exception => e
          flash[:error] = "Failed to delete report with error : " + e.message
        end
      end
      flash[:notice] = "#{count} reports have been removed";
      redirect_to request.env["HTTP_REFERER"]
    end
    
    
    private
    
    def _store_rectified_report
      ["book_number","code_number", "error", "error_message", 
        "field1","field2","field3","field4","field5",
        "meaning1","meaning2","meaning3","meaning4","meaning5","health_center_code","od_name","place","phone_number",
        "reply_to","sender_address","sender","slip_code","text","od"].each do |field|
           @report.send( "#{field}=", @rectify_report.send(field) )
       end
       @report.save
    end
    
    def _send_alert_to_other
      nuntium = Nuntium.new_from_config()
      nuntium.send_ao @report.send_others
    end
      
    
  end
end