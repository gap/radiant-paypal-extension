

module Paypal
  include Radiant::Taggable
  include ActionView::Helpers::FormHelper  
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper

  # Get the session information from the database.  This shouldn't be called
  def initSession
  	@session, id  = PaypalSession.initSession(response.session)

  	response.session[:paypal_session] = id
  	@session
  end
  
  #read session info
  def session
  	initSession
  	@session.data	
  end
  
  #write session info
  def session= value
  	initSession
  	@session.data = value
  	@session.save!
  end
  
  desc 'Paypal result'
  tag 'paypal:result' do |tag|
  	m = "This is the result #{session[:message]}"
  	m = session[:message]
  	@session.data[:message] = nil
  	@session.save!
  	"#{m}"
  end

  desc 'Creates a div for paypal messages.  Used for paypal:link'
  tag 'paypal:message' do |tag|
  	"<div id='paypal_message'> #{tag.expand} </div>"
  end 

  desc 'Display a link to add a product'
  tag 'paypal:link' do |tag| 
  	p = tag.locals.product
	p = Product.find_by_title(tag.attr['title']) unless p
	return "Product #{tag.attr['title']} is not found" unless p
  %{<a href="#" onclick="new Ajax.Updater('paypal_message', 'product/#{p.id}', {asynchronous:true, evalScripts:true}); return false;">#{p.expand(tag.expand)}</a>}	
  end

  tag 'paypal' do |tag|
  	tag.expand
  end

  desc 'Display the total for all the items'
  tag 'paypal:total' do |tag|   	
     number_to_currency(Order.total(session[:cart]))
  end

  tag 'paypal:item' do |tag|
  	tag.locals.product.itemExpand(tag.expand, tag.locals.count)
  end
  
  tag 'paypal:items' do |tag|
  	tag.expand
  end

  desc 'Display a cart item.  Can use the tags !cost, !price, !description, !name and !quantity'
  tag 'paypal:items:each' do |tag|
  	return "" if session[:cart] == nil  	
    result = []
    session[:cart].each_pair do |key, value|
    	p = Product.find(key)
    	tag.locals.product = p
    	tag.locals.count = value
    	result << tag.expand
    end
    result
  end

  desc %{Describes a specific product.  
  title=Products title
  Expand = Can use the tags !description, !name and !price 
}
  tag 'paypal:product' do |tag|
	#Return the value if we are in a each loop
	return "#{tag.locals.product.expand(tag.expand)}" if tag.locals.product

  	p = Product.find_by_title(tag.attr['title'])
  	return "Product #{tag.attr['title']} not found" unless p
  	ret = p.expand(tag.expand)
  	ret.to_s
  end

  tag 'paypal:products' do |tag|
  	tag.expand
  end

  desc 'Loop through all the avalible products'
  tag 'paypal:products:each' do |tag|
    result = []
    Product.find(:all, :order => 'name ASC').each do |product|
      tag.locals.product = product
      result << tag.expand
    end
    result
  end

  desc 'Loop through all the products'
  tag 'paypal:products:each:product' do |tag|
    product = tag.locals.product
    ret = product.expand(tag.expand)
    "#{ret}"
  end

  tag 'card' do |tag|
  	tag.expand
  end

  desc 'Creates the link for express checkout'
  tag 'paypal:card:express' do |tag|
    link_to image_tag("https://www.paypal.com/en_US/i/btn/btn_xpressCheckout.gif"), 'product/express'
  end



  desc 'Starts a form for enter credit card information'
  tag 'paypal:card:start_form' do |tag|
    %{<div id='paypal_form'>
      <form action="product/checkout" 
        method="post" 
        onsubmit="new Ajax.Updater('paypal_message', 'product/checkout', {asynchronous:true, evalScripts:true, parameters:Form.serialize(this)}); return false;">
}
  end

  desc 'Ends the credit card form'
  tag 'paypal:card:end_form' do |tag|
  	%{</form> 
  	</div>}
  end

  desc 'First Name for the checkout form'
  tag 'paypal:card:first_name' do |tag|
  	text_field(:card,:first_name)
  end

  desc 'Last Name for the checkout form'
  tag 'paypal:card:last_name' do |tag|
  	text_field(:card,:last_name)
  end

  desc 'Credit Card Number for the checkout form'
  tag 'paypal:card:number' do |tag|
  	text_field(:card,:number)
  end

  desc 'Verification number for checkout form'
  tag 'paypal:card:verification' do |tag|
  	text_field(:card,:verification)
  end

  desc 'Address for checkout form'
  tag 'paypal:card:address' do |tag|
  	text_field(:card,:address)
  end

  desc 'Address2 for checkout form'
  tag 'paypal:card:address2' do |tag|
  	text_field(:card,:address2)
  end

  desc 'City for checkout form'
  tag 'paypal:card:city' do |tag|
  	text_field(:card,:city)
  end

  desc 'State for checkout form'
  tag 'paypal:card:state' do |tag|
  	text_field(:card,:state)
  end

  desc 'Zip for checkout form'
  tag 'paypal:card:zip' do |tag|
  	text_field(:card,:zip)
  end

  desc 'Country for checkout form'
  tag 'paypal:card:country' do |tag|
  	text_field(:card,:country)
  end

  desc 'Notes for checkout form'
  tag 'paypal:card:notes' do |tag|
  	text_area(:card,:notes, {:rows=>3})
  end

  desc 'Email for checkout form'
  tag 'paypal:card:email' do |tag|
  	text_field(:card,:email)
  end

  desc 'Checkout tag'
  tag 'paypal:card:type' do |tag|
  	card = Hash.new
    card["Visa"] = 'visa'
    card["MasterCard"] = 'master'	
    card["Discover"] = 'discover'	
    card["American Express"] = 'american_express'	  	
	select( :card, :type, card)
  end
   
  desc 'Checkout tag'
  tag 'paypal:card:date' do |tag|
 	date_select(:card, :card_expires_on, :discard_day => true, :start_year => Date.
today.year, :end_year => (Date.today.year+10), :add_month_numbers => true)
  end
  
end  
