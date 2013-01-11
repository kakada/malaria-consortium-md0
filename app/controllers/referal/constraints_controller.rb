module Referal
  class ConstraintsController < ReferalController
    def index
      @field = Referal::Field.find params[:field_id]
      @constraints = @field.constraints
    end
    
    def new
      @field = Referal::Field.find params[:field_id]
      @constraint  = @field.constraints.build
    end
    
    def create
      @field = Referal::Field.find params[:field_id]
      item = Referal::ConstraintType::Validator.get_validator(params[:constraint_type], *params[:args])
      
      @constraint = @field.constraints.build
      @constraint.validator = item
      
      if @constraint.save
        flash[:notice] = "Constraint has been created successfully"
        redirect_to referal_field_constraints_path(@field)
      else
        flash.now[:notice] = "Failed to create constraint"
        render :new
      end
      
    end
    
    def destroy
      @field = Referal::Field.find params[:field_id]
      @constraint = @field.constraints.find params[:id]
      validator = @constraint.validator
      @constraint.delete
      flash[:notice] = "Constraint: <b>" + validator.to_s  + " </b> For: <b>" + @field.name + " </b> has been removed"
      redirect_to referal_field_constraints_path(@field)   
    end
    
    def edit
      render :json => params
    end
    
    def view
      raise "Type of view must be provided" if !params[:type].present?
      render :view, :layout => false
    end
    
  end
end