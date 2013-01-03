module Referal
  class MessageFormatsController < ReferalController
    def index
      @clinic = Referal::MessageFormat.first
      @hc     = Referal::MessageFormat.last
    end
  end
end