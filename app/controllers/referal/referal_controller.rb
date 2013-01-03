module Referal
  class ReferalController < ::ApplicationController
     layout "referal_layout"
     
     before_filter :load_path
     
    
     def load_path
       Dir["app/models/referal/constraint_type/*.rb"].each do |path|
          require_dependency path
       end
     end
  end
  
end