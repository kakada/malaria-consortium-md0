module Referal
  class ProvidersController < ReferalController
    def index
       render :json => User.paginate_user
    end
  end
end
