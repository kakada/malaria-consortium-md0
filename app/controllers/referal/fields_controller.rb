module Referal
  class FieldsController < ReferalController
    def index
      @fields = Referal::Field.all
    end
    
    def new
      raise "Name must be provided" if !params[:position].present?
      @field = Referal::Field.new :position => params[:position], :name => Referal::Field.columnize(params[:position])
    end
    
    def create
      @field = Referal::Field.new params[:referal_field]
      if(@field.save)
        flash[:notice] = "Field created"
        redirect_to referal_fields_path
      else
        flash[:error] = "Failed to create field"
        render :new
      end
    end
    
    def edit
      @field = Referal::Field.find params[:id]
     
    end
    
    def update
      @field = Referal::Field.find params[:id]
      if @field.update_attributes params[:referal_field]
        flash["notice"] = "Successfully Updated"
	      redirect_to referal_fields_path
  		else
  		  flash["error"] = "Failed to update"
	      render :edit
  		end
    end
    
    def destroy
      @field = Referal::Field.find params[:id]
      @field.destroy
      flash[:notice] = "#{@field.name} has been deleted"
      redirect_to referal_fields_path
    end
    
    def bulk_update
      message = "Fields updated"
      failed = false
      params[:referal_field].each do |id, position|
        field = Referal::Field.find id
        field.position = position
        if !field.save
          message = field.errors.full_messages.join("<br />")
          flash[:error] = " Some fields could not be saved with error : <b >" + message + "</b>"
          failed = true
        end
      end
      flash[:notice] = message if !failed
      
      redirect_to referal_fields_path
    end
    
    def constraint
      @field = Referal::Field.find params[:field_id]
      item = Referal::ConstraintType::Validator.get_validator(params[:constraint_type], *params[:args])

      @field.constraints = @field.constraints + [ item ]
      render :json => @field.constraints
    end
    
    def show
      @field = Referal::Field.find params[:id]
    end
    
  end
end