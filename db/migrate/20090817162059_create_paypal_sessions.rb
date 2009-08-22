class CreatePaypalSessions < ActiveRecord::Migration

  def self.configureData
  	[ {:key=>'Paypal.Configure.Password', :value=>''},
  	  {:key=>'Paypal.Configure.Signature', :value=>''},
  	  {:key=>'Paypal.Configure.Login',     :value=>''},
  	  {:key=>'Paypal.Message.Add Item',  :value=>'!name added.'},
  	  {:key=>'Paypal.Message.Email Missing',:value=>'Email Address is missing'},
  	  {:key=>'Paypal.Message.Card Invalid', :value=>'Card not valid - !messsage'},
  	  {:key=>'Paypal.Message.Transaction Failed', :value=>'Transaction failed - !messsage'},
  	  {:key=>'Paypal.Message.Express Cancelled', :value=>'Cancelled'},
  	  {:key=>'Paypal.Message.Express Succeeded', :value=>'Your purchase has been completed.'},
  	  {:key=>'Paypal.Message.Express Failed', :value=>'Problem with your purchase - !message.'},
  	  {:key=>'Paypal.Message.Card Succeeded', :value=>'Your purchase has been completed.'},  	  
  	  {:key=>'Paypal.Url.Express Cancelled', :value=>'/paypal/cancel'},
  	  {:key=>'Paypal.Url.Express Succeeded', :value=>'/paypal/succeeded'},
  	  {:key=>'Paypal.Url.Express Failed', :value=>'/paypal/failed'},
  	]
  end

  def self.up
    create_table :paypal_sessions do |t|
     t.string :data

     t.timestamps
    end
    
    configureData.each do |data|
    	v = Radiant::Config.find_by_key(data[:key])
    	unless v
    		k = Radiant::Config.new(data)
    		k.save!
		end 
	end    
  end

  def self.down
    drop_table :paypal_sessions

    configureData.each do |data|
    		v = Radiant::Config.find_by_key(data[:key])
    		Radiant::Config.delete(v) if v
	end    

  end
end
