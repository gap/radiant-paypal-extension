# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PaypalExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/paypal"
  
  define_routes do |map|
  	
	map.connect 'product/express', :controller=>'cart', :action=>'express', :method=>:get 
	map.connect 'product/express_success', :controller=>'cart', :action=>'express_success'
	map.connect 'product/express_cancel', :controller=>'cart', :action=>'express_cancel'
  	map.connect 'product/checkout', :controller => 'cart', :action => 'checkout'
  	map.connect 'product/purchased', :controller => 'cart', :action => 'purchased'
  	map.connect 'product/clear', :controller => 'cart', :action => 'clear'
  	map.connect 'product/:id', :controller => 'cart', :action => 'add_item'
  	
  	map.namespace :admin, :member => { :remove => :get } do |admin|
		admin.resources :products
  	end
  end
  
  def activate
   SiteController.class_eval{session :disabled => false}
   Page.send :include, Paypal
    admin.tabs.add "Products", "/admin/products", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Paypal"
  end
  
end
