module Referral
  class ReferralController < ::ApplicationController
     layout "referral_layout"
     
     before_filter :load_path
     
    
     def load_path
       Dir["app/models/referral/constraint_type/*.rb"].each do |path|
          require_dependency path
       end
     end
  end
  
end