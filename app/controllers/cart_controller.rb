
require "active_merchant"

class CartController < ApplicationController
	
	no_login_required
	protect_from_forgery :only => [:create] 
	before_filter :initSession
	
	gateway_login = {
	  :login => Radiant::Config.find_by_key('Paypal.Configure.Login').value.strip,
	  :password => Radiant::Config.find_by_key('Paypal.Configure.Password').value.strip,
	  :signature => Radiant::Config.find_by_key('Paypal.Configure.Signature').value.strip
	  }
	  
    ActiveMerchant::Billing::Base.mode = :test
    GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(gateway_login)
	PAYPAL = ActiveMerchant::Billing::PaypalExpressGateway.new(gateway_login)

	def configValue key
		Radiant::Config.find_by_key(key).value.strip
	end
	
	def initSession
  		@stored, id  = PaypalSession.initSession(session)
  		
  		session[:paypal_session] = id
  	end

	def add_item		
		id = params[:id]
		p = Product.find(id)
		
		@stored.data[:cart] = Hash.new unless @stored.data[:cart]
		@stored.data[:cart][id] = @stored.data[:cart][id] || 0
		@stored.data[:cart][id] += 1		
		@stored.save!
		
		render(:text=>p.itemExpand(configValue('Paypal.Message.Add Item'), @stored.data[:cart][id] ))
	end
	
	def checkout
	  if params[:card][:email].empty?
	  	render(:text=>configValue('Paypal.Message.Email Missing') )
	  	return
  	  end
  	  
	  ret = String.new

        # test values from http://www.merchantplus.com/resources/pages/credit-card-logos-and-test-numbers/

	    # :type   => "visa",
	    # :number => "4024007148673576",

	    # :type   => "master",
		# :number => '5431111111111111'
		
	    # :type   => "discover",
	    # :number => "6011601160116611",

	    # :type   => "american_express",
		# :number => '378282246310005'


      credit_card = ActiveMerchant::Billing::CreditCard.new(
	    :type               => params[:card][:type],
	    :number             => params[:card][:number],
	    :verification_value => params[:card][:verification],
	    :month              => params[:card]['card_expires_on(2i)'],
	    :year               => params[:card]['card_expires_on(1i)'],
	    :first_name         => params[:card][:first_name],
	    :last_name          => params[:card][:last_name]

	    )


      if credit_card.valid?
	    r = GATEWAY.purchase(Order.totalInCents(@stored.data[:cart]), credit_card, :ip=>request.remote_ip)
	    if r.success?
	    	process_order params[:card]
      		a1 = %{new Ajax.Updater('paypal_message', 'product/purchased', {asynchronous:true, evalScripts:true}); }
      		a2 = %{new Ajax.Updater('paypal_form', 'product/clear', {asynchronous:true, evalScripts:true}); }
      		ret = %{<img onload="#{a1}#{a2} return false;" src="images/paypal/dot.gif" alt="It didn't load" /><br/>This is a test}
  	    else
  	      ret = configValue('Paypal.Message.Transaction Failed')
  	      ret.gsub!(!message, r.message) 
	    end
	  else
  	      ret = configValue('Paypal.Message.Card Invalid')
  	      ret.gsub!(!message, r.credit_card.errors.full_messages.join('.')) 
      end
      render :text=>ret
	end
	
  def process_order p
	o = Order.new
	o.email = p[:email]
	o.first_name = p[:first_name]
	o.last_name = p[:last_name]
	o.email = p[:email]
	o.address = p[:address]
	o.address2 = p[:address2]
	o.city = p[:city]
	o.state = p[:state]
	o.zip = p[:zip]
	o.country = p[:country]
	o.notes = p[:notes]
	o.total_in_cents = Order.totalInCents(@stored.data[:cart])
    o.paypal_token = p[:paypal_token]
    o.paypal_id = p[:paypal_id]	
	o.save!
	@stored.data[:orderId] = o.id	   

	@stored.data[:cart].each_pair do |key, quantity|
		p = Product.find(key)
		i = OrderItem.new
		i.name = p.name
		i.price_in_cents = p.price_in_cents
		i.quantity = quantity
		o.order_items << i
	end	    	
	o.save!
	@stored.data[:cart] = nil
	@stored.save!
  end
	
  def express
  	ip = "http://#{request.env['HTTP_HOST']}/"
  	
  	session_id = session[:paypal_session]
  	
  	o = Order.new
  	total = Order.totalInCents(@stored.data[:cart])
  
    response = PAYPAL.setup_purchase(total,
      :ip                => request.remote_ip,
      :return_url        => "#{ip}product/express_success?session=#{session_id}",
      :cancel_return_url => "#{ip}product/express_cancel"
    )
  redirect_to PAYPAL.redirect_url_for(response.token)
  end
	
  def express_cancel
  	@stored.data[:message] = configValue('Paypal.Message.Express Cancelled')
	@stored.save!
  	redirect_to configValue('Paypal.Url.Express Cancelled')
  	# render :text=>configValue('Express Cancelled')
  end

  def express_success
	session[:paypal_session] = params[:session]
	initSession

  	
  	details = PAYPAL.details_for(params[:token])

  	total = Order.totalInCents(@stored.data[:cart])
	# total = 1234

	r = PAYPAL.purchase(total, 
		:ip=>request.remote_ip,
		:token=>params[:token],
		:payer_id=>params[:PayerID]
		)
	
	p=details.params

	if r.success?
		process_order(
			{ :email=>p['payer'], :first_name=>p['first_name'], :last_name=>p['last_name'],
			:address => p['street1'], :address2 => p['street2'], :city=>p['city_name'],
			:state=>p['state_or_province'], :zip=>p['postal_code'], :country=>p['payer_country'],
			:paypal_token=>params[:token], :paypal_id=>params[:PayerID] }
			)
  		# render :text=>configValue('Paypal.Message.Express Succeeded')
	  	@stored.data[:message] = configValue('Paypal.Message.Express Succeeded')
		@stored.save!
  		redirect_to configValue('Paypal.Url.Express Succeeded')
  	else
  		# render :text=>configValue('Paypal.Message.Express Failed')
	  	@stored.data[:message] = configValue('Paypal.Message.Express Failed')
		@stored.save!
	  	redirect_to configValue('Paypal.Url.Express Failed')
  	end  		
  end

  def purchased
    # @o = Order.find @stored.data[:orderId]
    render :text=>configValue('Paypal.Message.Card Succeeded')
  end
	
  def clear
    render :text=>''
  end
	
end
