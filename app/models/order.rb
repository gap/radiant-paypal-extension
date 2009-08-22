class Order < ActiveRecord::Base
  
  has_many :order_items
  serialize :first_name
	
  def self.total items
  	return 0 if items == nil
  	total = 0
    items.each_pair { |key, quantity| total += Product.find(key).price*quantity }
    total
  end

  def self.totalInCents items
  	total(items)*100
  end

end
