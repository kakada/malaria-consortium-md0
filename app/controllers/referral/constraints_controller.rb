module Referral
  class ConstraintsController < ReferralController
    def index
      @field = Referral::Field.find params[:field_id]
      @constraints = @field.constraints
      @referral_title = "Constraint List"
    end
    
    def new
      @field = Referral::Field.find params[:field_id]
      @constraint  = @field.constraints.build
      @referral_title = "New Constraint"
    end
    
    def create
      @field = Referral::Field.find params[:field_id]
      item = Referral::ConstraintType::Validator.get_validator(params[:constraint_type], *params[:args])
      
      @constraint = @field.constraints.build
      @constraint.validator = item
      
      if @constraint.save
        flash[:notice] = "Constraint has been created successfully"
        redirect_to referral_field_constraints_path(@field)
      else
        flash.now[:notice] = "Failed to create constraint"
        render :new
      end
      
    end
    
    def destroy
      @field = Referral::Field.find params[:field_id]
      @constraint = @field.constraints.find params[:id]
      validator = @constraint.validator
      @constraint.delete
      flash[:notice] = "Constraint: <b>" + validator.to_s  + " </b> For: <b>" + @field.name + " </b> has been removed"
      redirect_to referral_field_constraints_path(@field)   
    end
    
    def edit
      render :json => params
      @referral_title = "Edit Constraint"
    end
    
    def view
      raise "Type of view must be provided" if !params[:type].present?
      render :view, :layout => false
    end
    
  end
end