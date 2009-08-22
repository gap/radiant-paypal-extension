
include ActionView::Helpers::NumberHelper

class Product < ActiveRecord::Base
	
  def expand string
  	string.gsub!('!name', name)
  	string.gsub!('!price', number_to_currency(price) )
  	string.gsub!('!description', description)  	
  	string
  end

  def itemExpand string, quantity
  	string = expand(string)
  	string.gsub!('!quantity', quantity.to_s)
  	string.gsub!('!cost', "#{number_to_currency(quantity*price)}" )
  	string
  end
	
	
	def price_in_cents
		price * 100
	end
end
