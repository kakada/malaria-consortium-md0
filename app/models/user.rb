class User < ActiveRecord::Base
  has_one :place, :polymorphic => true
end
