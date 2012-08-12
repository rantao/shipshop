class Order < ActiveRecord::Base
  attr_accessible :customer_id, :item, :price
  belongs_to :customer
end
