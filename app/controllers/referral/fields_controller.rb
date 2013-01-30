module Referral
  class FieldsController < ReferralController
    def index
      @fields = Referral::Field.all
    end
    
    def new
      raise "Name must be provided" if !params[:position].present?
      @field = Referral::Field.new :position => params[:position], :name => Referral::Field.columnize(params[:position])
    end
    
    def create
      @field = Referral::Field.new params[:referral_field]
      if(@field.save)
        flash[:notice] = "Field created"
        redirect_to referral_fields_path
      else
        flash[:error] = "Failed to create field"
        render :new
      end
    end
    
    def edit
      @field = Referral::Field.find params[:id]
     
    end
    
    def update
      @field = Referral::Field.find params[:id]
      if @field.update_attributes params[:referral_field]
        flash["notice"] = "Successfully Updated"
	      redirect_to referral_fields_path
  		else
  		  flash["error"] = "Failed to update"
	      render :edit
  		end
    end
    
    def destroy
      @field = Referral::Field.find params[:id]
      @field.destroy
      flash[:notice] = "#{@field.name} has been deleted"
      redirect_to referral_fields_path
    end
    
    def bulk_update
      message = "Fields updated"
      failed = false
      params[:referral_field].each do |id, position|
        field = Referral::Field.find id
        field.position = position
        if !field.save
          message = field.errors.full_messages.join("<br />")
          flash[:error] = " Some fields could not be saved with error : <b >" + message + "</b>"
          failed = true
        end
      end
      flash[:notice] = message if !failed
      
      redirect_to referral_fields_path
    end
    
    def constraint
      @field = Referral::Field.find params[:field_id]
      item = Referral::ConstraintType::Validator.get_validator(params[:constraint_type], *params[:args])

      @field.constraints = @field.constraints + [ item ]
      render :json => @field.constraints
    end
    
    def show
      @field = Referral::Field.find params[:id]
    end
    
  end
end