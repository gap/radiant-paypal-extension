
class PaypalSession < ActiveRecord::Base
	serialize :data
	 
	def self.createSession
  		ret = PaypalSession.new 
  		ret.data = Hash.new
  		ret.save!
  		id = ret.id
  		return ret, id
	end
	
	def self.initSession session
		if session  && session[:paypal_session] 
			ret = find(session[:paypal_session])
			return ret, session[:paypal_session] if ret
		end
				
		#If we haven't found a sesions create one
		return createSession
  	rescue
		createSession  		
	end 	 
end
